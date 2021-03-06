package com.mr.flutter.plugin.pdfpreview.pdfpreviewer;

import android.graphics.Bitmap;
import android.graphics.pdf.PdfRenderer;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.util.concurrent.TimeUnit;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** PdfPreviewerPlugin */
@SuppressWarnings("ResultOfMethodCallIgnored")
public class PdfPreviewerPlugin implements MethodCallHandler {


  private final String TAG = "PDFPreviewer";
  private static Registrar instance;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "pdf_previewer");
    instance = registrar;
    clearTempFiles(instance.activeContext().getCacheDir());
    channel.setMethodCallHandler(new PdfPreviewerPlugin());
  }

  private void runOnUiThread(final Result result, final Object o, final boolean success){
    instance.activity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if(success) {
          result.success(o);
        } else {
          result.notImplemented();
        }
      }
    });
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {

    Thread thread = new Thread(new Runnable() {
      @Override
      public void run() {
        switch (call.method) {
          case "getPagePreview":
            runOnUiThread(result, getPagePreview((String) call.argument("filePath"), (int) call.argument("pageNumber"), false), true);
            break;
          case "getLastPagePreview":
            runOnUiThread(result, getPagePreview((String) call.argument("filePath"), 0, true),true);
            break;
          default:
            runOnUiThread(result, null, false);
            break;
        }
      }
    });

    thread.start();

  }


  private String getPagePreview(String filePath, int pageNumber,  boolean isLast) {

    File pdf = new File(filePath);

    try {
      PdfRenderer renderer = new PdfRenderer(ParcelFileDescriptor.open(pdf, ParcelFileDescriptor.MODE_READ_ONLY));

      Bitmap bitmap;
      final int pageCount = renderer.getPageCount();

      if(isLast) {
        pageNumber = pageCount-1;
      }else if(pageNumber > pageCount) {
        pageNumber = 0;
      }else {
        pageNumber--;
      }

        PdfRenderer.Page page = renderer.openPage(pageNumber);

        double width = instance.activity().getResources().getDisplayMetrics().densityDpi  * page.getWidth();
        double height = instance.activity().getResources().getDisplayMetrics().densityDpi  * page.getHeight();
        final double docRatio = width / height;

        width = 2048;
        height = (int)(width / docRatio);

        bitmap = Bitmap.createBitmap((int)width, (int)height, Bitmap.Config.ARGB_8888);

        page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY);

        try {
          return createTempPreview(bitmap);
        }finally {
          // close the page
          page.close();
          // close the renderer
          renderer.close();
        }
    } catch (Exception ex) {
      ex.printStackTrace();
    }

    return null;
  }

  private static boolean clearTempFiles(File fileOrDir){
    if (fileOrDir != null && fileOrDir.isDirectory()) {
      String[] children = fileOrDir.list();
      for (int i = 0; i < children.length; i++) {
        boolean success = clearTempFiles(new File(fileOrDir, children[i]));
        if (!success) {
          return false;
        }
      }
    }
    // The directory is now empty so delete it
    return fileOrDir.delete();
  }

  private String createTempPreview(Bitmap bmp){
    File tmpFiles = new File(instance.activeContext().getCacheDir(), TAG);
    tmpFiles.mkdirs();

    String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
    String fileName = "PDFPreviewPage-" + timeStamp + ".png";
    File file = new File(tmpFiles, fileName);
    Log.i(TAG, "" + file);

    if (file.exists()) {
      file.delete();
    }

    try {
      FileOutputStream out = new FileOutputStream(file);
      bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
      out.flush();
      out.close();
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }


    return file.getAbsolutePath();
  }
}
