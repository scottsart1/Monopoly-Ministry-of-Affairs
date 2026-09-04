package com.scottsart.velvetroulette;

import android.os.Bundle;
import android.view.WindowManager;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        registerPlugin(VelvetPlugin.class);
        super.onCreate(savedInstanceState);
        // Private from the very first frame; the page switches it off if the menu setting says so.
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
    }
}
