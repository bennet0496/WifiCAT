package de.becker_dd.bennet.wificat;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.net.wifi.SupplicantState;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiEnterpriseConfig;
import android.net.wifi.WifiManager;
import android.security.KeyChain;
import android.security.KeyChainAliasCallback;
import android.security.KeyChainException;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.app.LoaderManager.LoaderCallbacks;

import android.content.CursorLoader;
import android.content.Loader;
import android.database.Cursor;
import android.net.Uri;

import android.os.Build;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;

import android.util.Base64;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import java.io.ByteArrayInputStream;
import java.security.NoSuchProviderException;
import java.security.Principal;
import java.security.PrivateKey;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;

import javax.security.auth.x500.X500Principal;

import static android.support.v7.app.AlertDialog.*;

/**
 * A login screen that offers login via email/password.
 */
public class LoginWifiNetworkActivity extends AppCompatActivity implements LoaderCallbacks<Cursor> {

    // UI references.
    private EditText mUsernameView;
    private EditText mPasswordView;
    private View mProgressView;
    private View mLoginFormView;

    private Resources res;
    private PrivateKey privateKey;
    private X509Certificate[] certChain;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        res = getResources();
        setContentView(R.layout.activity_login_wifi_network);
        // Set up the login form.
        mUsernameView = (EditText) findViewById(R.id.username);

        mPasswordView = (EditText) findViewById(R.id.password);
        mPasswordView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == R.id.login || id == EditorInfo.IME_NULL) {
                    try {
                        attemptLogin();
                    } catch (Exception e) {
                        e.printStackTrace();
                        String trace = e.toString() + "\n";
                        for (StackTraceElement el: e.getStackTrace()) {
                            trace += "\tat " + el.toString();
                        }
                        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(textView.getContext());
                        alertDialogBuilder.setTitle("Error!");
                        alertDialogBuilder.setMessage(trace);
                        alertDialogBuilder.setPositiveButton("Ok",
                                new DialogInterface.OnClickListener() {

                                    @Override
                                    public void onClick(DialogInterface arg0, int arg1) {
                                        showProgress(false);
                                        mLoginFormView.requestFocus();
                                        arg0.dismiss();
                                    }
                                });
                        AlertDialog alertDialog = alertDialogBuilder.create();
                        alertDialog.show();
                    }
                    return true;
                }
                return false;
            }
        });

        Button mChooseClientCertButton = (Button) findViewById(R.id.choose_cert);
        if(res.getBoolean(R.bool.use_client_cert)) {
            mChooseClientCertButton.setVisibility(View.VISIBLE);

            mChooseClientCertButton.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (Build.VERSION.SDK_INT >= 23) {
                        KeyChain.choosePrivateKeyAlias(LoginWifiNetworkActivity.this, new KeyChainAliasCallback() {
                                    @Override
                                    public void alias(@Nullable String alias) {
                                        try {
                                            LoginWifiNetworkActivity.this.privateKey = KeyChain.getPrivateKey(LoginWifiNetworkActivity.this.getApplicationContext(), alias);
                                            LoginWifiNetworkActivity.this.certChain = KeyChain.getCertificateChain(LoginWifiNetworkActivity.this.getApplicationContext(), alias);
                                            System.out.println(LoginWifiNetworkActivity.this.privateKey);
                                            System.out.println(LoginWifiNetworkActivity.this.certChain);
                                        } catch (KeyChainException e) {
                                            e.printStackTrace();
                                        } catch (InterruptedException e) {
                                            e.printStackTrace();
                                        }
                                    }
                                }, null,
                                new Principal[]{new X500Principal(getString(R.string.client_cert_issuer))}, null, null);
                    }
                }
            });
        }

        Button mNetworkInstallButton = (Button) findViewById(R.id.install_network_button);
        mNetworkInstallButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                try {
                    attemptLogin();
                } catch (Exception e) {
                    e.printStackTrace();
                    String trace = e.toString() + "\n";
                    for (StackTraceElement el: e.getStackTrace()) {
                        trace += "\tat " + el.toString() + "\n";
                    }
                    AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(view.getContext());
                    alertDialogBuilder.setTitle("Error!");
                    alertDialogBuilder.setMessage(trace);
                    alertDialogBuilder.setPositiveButton("Ok",
                            new DialogInterface.OnClickListener() {

                                @Override
                                public void onClick(DialogInterface arg0, int arg1) {
                                    showProgress(false);
                                    mLoginFormView.requestFocus();
                                    arg0.dismiss();
                                }
                            });
                    AlertDialog alertDialog = alertDialogBuilder.create();
                    alertDialog.show();
                }
            }
        });

        mLoginFormView = findViewById(R.id.login_form);
        mProgressView = findViewById(R.id.login_progress);
    }

    private void attemptLogin() throws CertificateException, NoSuchProviderException {
        // Reset errors.
        mUsernameView.setError(null);
        mPasswordView.setError(null);

        // Store values at the time of the login attempt.
        String user = mUsernameView.getText().toString();
        String password = mPasswordView.getText().toString();

        boolean cancel = false;
        View focusView = null;

        // Check for a valid password, if the user entered one.
        if (!TextUtils.isEmpty(password) && !isPasswordValid(password)) {
            mPasswordView.setError(getString(R.string.error_field_required));
            focusView = mPasswordView;
            cancel = true;
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(user)) {
            mUsernameView.setError(getString(R.string.error_field_required));
            focusView = mUsernameView;
            cancel = true;
        }

        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            // Show a progress spinner, and kick off a background task to
            // perform the user login attempt.
            showProgress(true);

            WifiManager wifi = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);



            WifiConfiguration configuration = new WifiConfiguration();
            WifiEnterpriseConfig enterpriseConfig = new WifiEnterpriseConfig();

            X509Certificate cert = convertToX509Cert(getString(R.string.ca_certificate));

            configuration.SSID = getString(R.string.SSID);
            configuration.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_EAP);

            enterpriseConfig.setIdentity(user);
            enterpriseConfig.setPassword(password);
            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                enterpriseConfig.setAltSubjectMatch(getString(R.string.subject_alt_match));
                enterpriseConfig.setDomainSuffixMatch(getString(R.string.dns_suffix_match));
            }
            if(res.getBoolean(R.bool.use_client_cert)){
                enterpriseConfig.setClientKeyEntry(privateKey, certChain[0]);
            }


            enterpriseConfig.setAnonymousIdentity(getString(R.string.anonymous_identity));
            enterpriseConfig.setEapMethod(res.getInteger(R.integer.eap_method));
            enterpriseConfig.setPhase2Method(res.getInteger(R.integer.phase2_method));
            enterpriseConfig.setCaCertificate(cert);
            //enterpriseConfig.setClientCertificateAlias(cert);

            configuration.enterpriseConfig = enterpriseConfig;

            int networkid = wifi.addNetwork(configuration);
            wifi.enableNetwork(networkid, true);

            boolean success = false;

            for(int i = 0; i < 5; i++) {
                if (wifi.getConnectionInfo().getSupplicantState() == SupplicantState.COMPLETED &&
                        wifi.getConnectionInfo().getNetworkId() == networkid) {
                    success = true;
                    break;
                }else{
                    System.out.println("Wifi not connected. Waiting.");
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }

            AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(this);
            DialogInterface.OnClickListener uninstaller = new DialogInterface.OnClickListener() {

                @Override
                public void onClick(DialogInterface arg0, int arg1) {
                    Uri packageURI = Uri.parse("package:" + LoginWifiNetworkActivity.class.getPackage().getName());
                    Intent uninstallIntent = new Intent(Intent.ACTION_DELETE, packageURI);
                    startActivity(uninstallIntent);
                }
            };
            DialogInterface.OnClickListener dismiss = new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface arg0, int arg1) {
                    showProgress(false);
                    mLoginFormView.requestFocus();
                    arg0.dismiss();
                }
            };

            DialogInterface.OnClickListener exit = new DialogInterface.OnClickListener() {

                @Override
                public void onClick(DialogInterface arg0, int arg1) {
                    System.exit(0);
                }
            };

            if (success) {
                alertDialogBuilder.setTitle("Done");
                alertDialogBuilder.setMessage("Network added successfully. Do you want to uninstall the now?");
                alertDialogBuilder.setPositiveButton("Yes", uninstaller);
                alertDialogBuilder.setNegativeButton("No",dismiss);
            }else{
                alertDialogBuilder.setTitle("Done");
                alertDialogBuilder.setMessage("Network added, but it seams the Network is not connecting");
                alertDialogBuilder.setPositiveButton("Try again", dismiss);
                alertDialogBuilder.setNegativeButton("Close", exit);
                alertDialogBuilder.setNeutralButton("Uninstall App", uninstaller);
            }
            alertDialogBuilder.setOnCancelListener(new DialogInterface.OnCancelListener() {
                @Override
                public void onCancel(DialogInterface dialog) {
                    showProgress(false);
                    mLoginFormView.requestFocus();
                    dialog.dismiss();
                }
            });
            AlertDialog alertDialog = alertDialogBuilder.create();
            alertDialog.show();
        }
    }

    private static X509Certificate convertToX509Cert(String certificateString) throws CertificateException {
        X509Certificate certificate = null;
        CertificateFactory cf = null;
        try {
            if (certificateString != null && !certificateString.trim().isEmpty()) {
                certificateString = certificateString.replace("-----BEGIN CERTIFICATE-----", "")
                        .replace("-----END CERTIFICATE-----", "").replace("\n", "").trim(); // NEED FOR PEM FORMAT CERT STRING
                byte[] certificateData = Base64.decode(certificateString, Base64.DEFAULT);
                cf = CertificateFactory.getInstance("X509");
                certificate = (X509Certificate) cf.generateCertificate(new ByteArrayInputStream(certificateData));
            }
        } catch (CertificateException e) {
            throw new CertificateException(e);
        }
        return certificate;
    }

    private boolean isPasswordValid(String password) {
        //TODO: Replace this with your own logic
        return password.length() > 4;
    }

    /**
     * Shows the progress UI and hides the login form.
     */
    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR2)
    private void showProgress(final boolean show) {
        // On Honeycomb MR2 we have the ViewPropertyAnimator APIs, which allow
        // for very easy animations. If available, use these APIs to fade-in
        // the progress spinner.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR2) {
            int shortAnimTime = getResources().getInteger(android.R.integer.config_shortAnimTime);

            mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
            mLoginFormView.animate().setDuration(shortAnimTime).alpha(
                    show ? 0 : 1).setListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
                }
            });

            mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
            mProgressView.animate().setDuration(shortAnimTime).alpha(
                    show ? 1 : 0).setListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
                }
            });
        } else {
            // The ViewPropertyAnimator APIs are not available, so simply show
            // and hide the relevant UI components.
            mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
            mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
        }
    }

    @Override
    public Loader<Cursor> onCreateLoader(int i, Bundle bundle) {
        return new CursorLoader(this);
    }

    @Override
    public void onLoadFinished(Loader<Cursor> cursorLoader, Cursor cursor) {

    }

    @Override
    public void onLoaderReset(Loader<Cursor> cursorLoader) {

    }

    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
           case R.id.action_info:
               Builder ad = new Builder(mLoginFormView.getContext());
               ad.setMessage(getString(R.string.appinfo));
               ad.setIcon(R.drawable.ic_info_black_24dp);
               ad.setNeutralButton("Close", new DialogInterface.OnClickListener() {
                   @Override
                   public void onClick(DialogInterface dialog, int which) {
                       dialog.dismiss();
                   }
               });

               ad.show();
               return true;

            default:
                // If we got here, the user's action was not recognized.
               // Invoke the superclass to handle it.
               return super.onOptionsItemSelected(item);

        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.topmenu, menu);
        return true;
    }

}

