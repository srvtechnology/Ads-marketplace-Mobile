package com.dpm.payment.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import androidx.collection.LruCache;

import com.android.volley.RequestQueue;
import com.android.volley.toolbox.HurlStack;
import com.android.volley.toolbox.ImageLoader;
import com.android.volley.toolbox.Volley;

public final class VolleySingleton
{

    private static VolleySingleton mInstance = null;
    private RequestQueue mRequestQueue;
    private ImageLoader imageLoader;

    private VolleySingleton(Context context)
    {
        /*HurlStack stack = new HurlStack()
        {
            @Override
            protected HttpURLConnection createConnection(URL url) throws IOException
            {
                HttpURLConnection connection = super.createConnection(url);
                connection.setInstanceFollowRedirects(false);
                return connection;
            }
        };*/
        HurlStack stack = new MyHurlStack();
        mRequestQueue = Volley.newRequestQueue(context, stack);
        imageLoader = new ImageLoader(mRequestQueue,
                new ImageLoader.ImageCache()
                {
                    private final LruCache<String, Bitmap>
                            // NOTE: Hardcoded to 200 for simplicity - needs to be
                            // modified based on the memory capacity of the
                            // device.
                            cache = new LruCache<String, Bitmap>(200);

                    @Override
                    public Bitmap getBitmap(String url)
                    {
                        if (url.contains("file://")) {
                            return BitmapFactory.decodeFile(url.substring(url.indexOf("file://") + 7));
                        } else {
                            // Here you can add an actual cache
                            return null;
                        }
                        //return cache.get(url);
                    }

                    @Override
                    public void putBitmap(String url, Bitmap bitmap)
                    {
                        cache.put(url, bitmap);
                    }
                });
    }

    public static synchronized VolleySingleton getInstance(Context context)
    {
        if (mInstance == null)
        {
            mInstance = new VolleySingleton(context);
        }
        return mInstance;
    }

    public ImageLoader getImageLoader()
    {
        return imageLoader;
    }

    public RequestQueue getRequestQueue()
    {
        return this.mRequestQueue;
    }
}
