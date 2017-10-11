package com.creative.informatics.camera;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.os.Bundle;
import android.util.Base64;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

/**
 * Created by K on 9/29/2017.
 */

public class ResultActivity extends Activity {

    private Bitmap mResultBmp;
    private Bitmap mFinalBmp;
    private ImageView imgView;
    private Button rotateButton;
    private Button finishButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getResources().getIdentifier("result_view", "layout", getPackageName()));

        imgView = (ImageView)findViewById(getResources().getIdentifier("resultview", "id", getPackageName()));
        String path = getIntent().getStringExtra("resultpath");
        mResultBmp = BitmapFactory.decodeFile(path);
        imgView.setImageBitmap(mResultBmp);

        rotateButton = (Button)findViewById(getResources().getIdentifier("rotate", "id", getPackageName()));

        rotateButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mFinalBmp = RotateBitmap(mResultBmp,90);
                imgView.setImageBitmap(mFinalBmp);
                mResultBmp = mFinalBmp;
            }
        });

    }

    public static Bitmap RotateBitmap(Bitmap source, float angle)
    {
        Matrix matrix = new Matrix();
        matrix.postRotate(angle);
        return Bitmap.createBitmap(source, 0, 0, source.getWidth(), source.getHeight(), matrix, true);
    }


}
