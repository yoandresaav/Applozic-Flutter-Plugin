package com.example.applozic_flutter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.text.TextUtils;
import android.util.Log;

import com.applozic.mobicomkit.Applozic;
import com.applozic.mobicomkit.api.account.register.RegistrationResponse;
import com.applozic.mobicomkit.api.account.user.AlUserUpdateTask;
import com.applozic.mobicomkit.api.account.user.User;
import com.applozic.mobicomkit.api.account.user.UserDetail;
import com.applozic.mobicomkit.api.account.user.UserService;
import com.applozic.mobicomkit.api.people.ChannelInfo;
import com.applozic.mobicomkit.feed.ChannelFeedApiResponse;
import com.applozic.mobicomkit.listners.AlCallback;
import com.applozic.mobicomkit.listners.AlLoginHandler;
import com.applozic.mobicomkit.listners.AlLogoutHandler;
import com.applozic.mobicomkit.listners.AlPushNotificationHandler;
import com.applozic.mobicomkit.uiwidgets.async.AlChannelCreateAsyncTask;
import com.applozic.mobicomkit.uiwidgets.async.AlGroupInformationAsyncTask;
import com.applozic.mobicomkit.uiwidgets.conversation.ConversationUIService;
import com.applozic.mobicomkit.uiwidgets.conversation.activity.ConversationActivity;
import com.applozic.mobicommons.json.GsonUtils;
import com.applozic.mobicommons.people.channel.Channel;
import com.applozic.mobicomkit.api.account.user.MobiComUserPreference;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * ApplozicFlutterPlugin
 */
public class ApplozicFlutterPlugin implements MethodCallHandler {
    /**
     * Plugin registration.
     */
    private static final String SUCCESS = "Success";
    private static final String ERROR = "Error";
    private Activity context;
    private MethodChannel methodChannel;

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "applozic_flutter");
        channel.setMethodCallHandler(new ApplozicFlutterPlugin(registrar.activity(), channel));
    }

    public ApplozicFlutterPlugin(Activity activity, MethodChannel methodChannel) {
        this.context = activity;
        this.methodChannel = methodChannel;
        this.methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(final MethodCall call, final Result result) {
        if (call.method.equals("login")) {
            User user = (User) GsonUtils.getObjectFromJson(GsonUtils.getJsonFromObject(call.arguments, Object.class), User.class);

            final String firebaseId = call.argument("firebaseId");

            if (!TextUtils.isEmpty(user.getApplicationId())) {
                Applozic.init(context, user.getApplicationId());
            }
            Applozic.connectUser(context, user, new AlLoginHandler() {
                @Override
                public void onSuccess(RegistrationResponse registrationResponse, Context context) {

                    Applozic.registerForPushNotification(context, firebaseId, new AlPushNotificationHandler() {
                        @Override
                        public void onSuccess(RegistrationResponse registrationResponse) {
                            //Log("SUCCESS DENTRO", "Se registro");
                        }

                        @Override
                        public void onFailure(RegistrationResponse registrationResponse, Exception exception) {
                            //Log("NO SUCCESS NADA", "No se registro");
                        }
                    });
                    result.success(GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class));
                }

                @Override
                public void onFailure(RegistrationResponse registrationResponse, Exception exception) {
                    result.error(ERROR, GsonUtils.getJsonFromObject(registrationResponse != null ? registrationResponse : exception, registrationResponse != null ? RegistrationResponse.class : Exception.class), null);
                }
            });
        } else if (call.method.equals("isLoggedIn")) {
            result.success(Applozic.isConnected(context));
        } else if (call.method.equals("logout")) {
            Applozic.logoutUser(context, new AlLogoutHandler() {
                @Override
                public void onSuccess(Context context) {
                    result.success(SUCCESS);
                }

                @Override
                public void onFailure(Exception exception) {
                    result.error(ERROR, "Some internal error occurred", exception);
                }
            });
        } else if (call.method.equals("launchChat")) {
            Intent intent = new Intent(context, ConversationActivity.class);
            context.startActivity(intent);
        } else if (call.method.equals("launchChatWithUser")) {
            try {
                Intent intent = new Intent(context, ConversationActivity.class);
                intent.putExtra(ConversationUIService.USER_ID, (String) call.arguments);
                intent.putExtra(ConversationUIService.TAKE_ORDER, true);
                context.startActivity(intent);
                result.success(SUCCESS);
            } catch (Exception e) {
                result.error(ERROR, e.getLocalizedMessage(), null);
            }
        } else if (call.method.equals("launchChatWithGroupId")) {
            try {
                Integer groupId = 0;
                if (call.arguments instanceof Integer) {
                    groupId = (Integer) call.arguments;
                } else if (call.arguments instanceof String) {
                    groupId = Integer.valueOf((String) call.arguments);
                } else {
                    result.error(ERROR, "Invalid groupId", null);
                }

                if (groupId == 0) {
                    result.error(ERROR, "Invalid groupId", null);
                    return;
                }

                new AlGroupInformationAsyncTask(context, groupId, new AlGroupInformationAsyncTask.GroupMemberListener() {
                    @Override
                    public void onSuccess(Channel channel, Context context) {
                        Intent intent = new Intent(context, ConversationActivity.class);
                        intent.putExtra(ConversationUIService.GROUP_ID, channel.getKey());
                        intent.putExtra(ConversationUIService.TAKE_ORDER, true);
                        context.startActivity(intent);
                        result.success(GsonUtils.getJsonFromObject(channel, Channel.class));
                    }

                    @Override
                    public void onFailure(Channel channel, Exception e, Context context) {
                        result.error(ERROR, e != null ? e.getLocalizedMessage() : "Some internal error occurred", null);
                    }
                }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
            } catch (Exception e) {
                result.error(ERROR, e.getLocalizedMessage(), null);
            }
        } else if (call.method.equals("createGroup")) {
            ChannelInfo channelInfo = (ChannelInfo) GsonUtils.getObjectFromJson(GsonUtils.getJsonFromObject(call.arguments, Object.class), ChannelInfo.class);
            new AlChannelCreateAsyncTask(context, channelInfo, new AlChannelCreateAsyncTask.TaskListenerInterface() {
                @Override
                public void onSuccess(Channel channel, Context context) {
                    result.success(String.valueOf(channel.getKey()));
                }

                @Override
                public void onFailure(ChannelFeedApiResponse channelFeedApiResponse, Context context) {
                    result.error(ERROR, channelFeedApiResponse != null ? GsonUtils.getJsonFromObject(channelFeedApiResponse, ChannelFeedApiResponse.class) : "Some internal error occurred", null);
                }
            }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        } else if (call.method.equals("updateUserDetail")) {
            try {
                if (Applozic.isConnected(context)) {
                    User user = (User) GsonUtils.getObjectFromJson(GsonUtils.getJsonFromObject(call.arguments, Object.class), User.class);
                    new AlUserUpdateTask(context, user, new AlCallback() {
                        @Override
                        public void onSuccess(Object message) {
                            result.success(SUCCESS);
                        }

                        @Override
                        public void onError(Object error) {
                            result.error(ERROR, "Unable to update user details", null);
                        }
                    }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
                } else {
                    result.error(ERROR, "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the user details", null);
                }
            } catch (Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if (call.method.equals("updateFirebaseFCM")) {
            // FIREBASE UPDATE
            try {
                if (Applozic.isConnected(context)) {
                    User user = (User) GsonUtils.getObjectFromJson(GsonUtils.getJsonFromObject(call.arguments, Object.class), User.class);
                    new AlUserUpdateTask(context, user, new AlCallback() {
                        @Override
                        public void onSuccess(Object message) {
                            result.success(SUCCESS);
                        }

                        @Override
                        public void onError(Object error) {
                            result.error(ERROR, "Unable to update user details", null);
                        }
                    }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
                } else {
                    result.error(ERROR, "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the user details", null);
                }
            } catch (Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if (call.method.equals("addContacts")) {
            UserDetail[] userDetails = (UserDetail[]) GsonUtils.getObjectFromJson(GsonUtils.getJsonFromObject(call.arguments, Object.class), UserDetail[].class);
            for (UserDetail userDetail : userDetails) {
                UserService.getInstance(context).processUser(userDetail);
            }
            result.success(SUCCESS);
        } else if (call.method.equals("getLoggedInUserId")) {
            String userId = MobiComUserPreference.getInstance(context).getUserId();
            if (!TextUtils.isEmpty(userId)) {
                result.success(userId);
            } else {
                result.error(ERROR, "User not authorised. UserId is empty", null);
            }
        } else {
            result.notImplemented();
        }
    }
}
