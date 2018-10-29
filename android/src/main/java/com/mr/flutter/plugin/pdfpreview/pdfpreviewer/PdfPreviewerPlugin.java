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
  private final String PATH = "/PDFPreviewer";
  private static Registrar instance;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "pdf_previewer");
    instance = registrar;
    clearTempFiles(new File(Environment.getExternalStorageDirectory().toString() + "/PDFPreviewer"));
    channel.setMethodCallHandler(new PdfPreviewerPlugin());
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {

    Thread thread = new Thread(new Runnable() {
      @Override
      public void run() {
        switch (call.method) {
          case "getPagePreview":
            result.success(getPagePreview((String) call.argument("filePath"), (int) call.argument("pageNumber"), false));
            break;
          case "getLastPagePreview":
            result.success(getPagePreview((String) call.argument("filePath"), 0, true));
            break;
          default:
            result.notImplemented();
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

        int width = instance.activity().getResources().getDisplayMetrics().densityDpi / 72 * page.getWidth();
        int height = instance.activity().getResources().getDisplayMetrics().densityDpi / 72 * page.getHeight();
        bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);

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

  private static void clearTempFiles(File fileOrDir){
      if (fileOrDir.isDirectory() && fileOrDir.listFiles() != null)
          for (File child : fileOrDir.listFiles())
              clearTempFiles(child);

      fileOrDir.delete();
  }

  private String createTempPreview(Bitmap bmp){

    String root = Environment.getExternalStorageDirectory().toString();
    File tmpFiles = new File(root + PATH);
    tmpFiles.mkdirs();

    String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
    String fileName = "PDFPreviewPage-" + timeStamp + ".png";
    File file = new File(tmpFiles, fileName);
    Log.i(TAG, "" + file);

    if (file.exists())
      file.delete();
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
