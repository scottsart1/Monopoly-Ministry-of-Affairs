package com.scottsart.velvetroulette;

import android.view.WindowManager;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

/**
 * The two window flags the page needs, with no permissions and no third-party plugin.
 *   Capacitor.Plugins.Velvet.setSecure({on})  — FLAG_SECURE: blank in the app switcher, screenshots blocked
 *   Capacitor.Plugins.Velvet.keepAwake({on})  — FLAG_KEEP_SCREEN_ON while a round, scene or session is open
 */
@CapacitorPlugin(name = "Velvet")
public class VelvetPlugin extends Plugin {
    private void flag(final PluginCall call, final int flag) {
        final boolean on = call.getBoolean("on", true);
        getActivity().runOnUiThread(() -> {
            if (on) {
                getActivity().getWindow().addFlags(flag);
            } else {
                getActivity().getWindow().clearFlags(flag);
            }
            JSObject result = new JSObject();
            result.put("on", on);
            call.resolve(result);
        });
    }

    @PluginMethod
    public void setSecure(PluginCall call) {
        flag(call, WindowManager.LayoutParams.FLAG_SECURE);
    }

    @PluginMethod
    public void keepAwake(PluginCall call) {
        flag(call, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }
}
