package com.zhangtom.nginxdemo;

import android.content.res.AssetManager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import com.jrummyapps.android.shell.CommandResult;
import com.jrummyapps.android.shell.Shell;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class MainActivity extends AppCompatActivity {

    private String mNginxDir;
    private static final String EXE_FILE_RELATIVE_PATH = "/sbin/nginx";
    private static final String CONF_FILE_RELATIVE_PATH = "/conf/nginx.conf";
    private static final String TAG = "NGX_DEBUG";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mNginxDir = getAppDataDir() + "/nginx";
        Button installButton = findViewById(R.id.installButton);
        installButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                copyFileOrDirFromAsset("nginx");
                CommandResult result = Shell.SH.run("chmod -R 755 " + mNginxDir);
                Log.w(TAG, result.exitCode + "\n" + result.stdout + "\n" + result.stderr);
            }
        });

        Button startButton = findViewById(R.id.startButton);
        startButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                CommandResult result = Shell.SH.run(mNginxDir + EXE_FILE_RELATIVE_PATH + " -p " + mNginxDir + " -c " + mNginxDir + CONF_FILE_RELATIVE_PATH);
                Log.w(TAG, result.exitCode + "\n" + result.stdout + "\n" + result.stderr);
            }
        });

        Button stopButton = findViewById(R.id.stopButton);
        stopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                CommandResult result = Shell.SH.run(mNginxDir + EXE_FILE_RELATIVE_PATH + " -p " + mNginxDir + " -s quit");
                Log.w(TAG, result.exitCode + "\n" + result.stdout + "\n" + result.stderr);
            }
        });
    }

    private String getAppDataDir() {
        return getApplicationInfo().dataDir;
    }

    private void copyFileOrDirFromAsset(String path) {
        AssetManager assetManager = this.getAssets();
        String assets[];
        try {
            assets = assetManager.list(path);
            if (assets.length == 0) {
                copyFile(path);
            } else {
                String fullPath = getAppDataDir() + "/" + path;
                File dir = new File(fullPath);
                if (!dir.exists())
                    dir.mkdir();
                for (String asset : assets) {
                    copyFileOrDirFromAsset(path + "/" + asset);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void copyFile(String filename) {
        AssetManager assetManager = this.getAssets();

        InputStream in;
        OutputStream out;
        try {
            in = assetManager.open(filename);
            String newFileName = getAppDataDir() + "/" + filename;
            out = new FileOutputStream(newFileName);

            byte[] buffer = new byte[1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            in.close();
            out.flush();
            out.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
