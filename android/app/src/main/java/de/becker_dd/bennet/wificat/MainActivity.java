package de.becker_dd.bennet.wificat;

import android.app.KeyguardManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Build;
import android.provider.Settings;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.view.MenuItem;
import android.widget.ProgressBar;

import com.jaredrummler.android.device.DeviceName;
import com.scottyab.rootbeer.RootBeer;

import java.util.Arrays;

public class MainActivity extends AppCompatActivity {

    private ProgressBar mProgressBar;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        boolean canCont = true;
        mProgressBar = (ProgressBar) findViewById(R.id.progressBar);
        RootBeer rootBeer = new RootBeer(getApplicationContext());
        rootBeer.setLogging(true);
        if(rootBeer.isRooted() && getResources().getBoolean(R.bool.disallow_root)){
            AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(mProgressBar.getContext());
            dialogBuilder.setTitle(getString(R.string.msg_snap));
            dialogBuilder.setMessage(getString(R.string.msg_rooted_device));
            dialogBuilder.setOnDismissListener(new DialogInterface.OnDismissListener() {
                @Override
                public void onDismiss(DialogInterface dialog) {
                    System.exit(0);
                }
            });
            dialogBuilder.create().show();
            canCont = false;
        }

        if(!(arrayContainsStringIgnoreCase(getResources().getStringArray(R.array.allowed_brands), Build.MANUFACTURER) ||
                (Build.BRAND.equalsIgnoreCase("Android") && Build.MODEL.startsWith("Android SDK built"))) &&
                getResources().getBoolean(R.bool.reputable_brand_required)){
            AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(MainActivity.this.mProgressBar.getContext());
            dialogBuilder.setTitle(getString(R.string.msg_snap));
            dialogBuilder.setMessage(getString(R.string.msg_not_trusted));
            dialogBuilder.setOnDismissListener(new DialogInterface.OnDismissListener() {
                @Override
                public void onDismiss(DialogInterface dialog) {
                    System.exit(0);
                }});
            dialogBuilder.create().show();
            canCont = false;
        }
        System.out.println(arrayContainsStringIgnoreCase(getResources().getStringArray(R.array.allowed_brands), Build.MANUFACTURER));
        System.out.println((Build.BRAND.equalsIgnoreCase("Android")  && Build.MODEL.startsWith("Android SDK built")));
        System.out.println(Build.MODEL);

        if(!((KeyguardManager)getSystemService(Context.KEYGUARD_SERVICE)).isKeyguardSecure() &&
                ((TelephonyManager)getSystemService(Context.TELEPHONY_SERVICE)).getSimState() != TelephonyManager.SIM_STATE_NETWORK_LOCKED &&
                getResources().getBoolean(R.bool.require_pin)){
            AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(MainActivity.this.mProgressBar.getContext());
            dialogBuilder.setTitle(getString(R.string.msg_snap));
            dialogBuilder.setMessage(getString(R.string.msg_no_pin));
            dialogBuilder.setNeutralButton(getString(R.string.open_settings), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    startActivity(new Intent(Settings.ACTION_SECURITY_SETTINGS));
                }
            });
            dialogBuilder.setOnDismissListener(new DialogInterface.OnDismissListener() {
                @Override
                public void onDismiss(DialogInterface dialog) {
                    System.exit(0);
                }});
            dialogBuilder.create().show();
            canCont = false;
        }

        if(canCont)
            startActivity(new Intent(this, LoginWifiNetworkActivity.class));
    }

    private static boolean arrayContainsStringIgnoreCase(String[] array, String search){
        for(String s : array){
            //System.err.println(s + " ? " + search + " -> " + s.equalsIgnoreCase(search));
            if(s.equalsIgnoreCase(search))
                    return true;
        }
        return false;
    }
    public boolean onOptionsItemSelected(MenuItem item) {
        return super.onOptionsItemSelected(item);
    }
}
