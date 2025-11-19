package com.dpm.payment.utils;

import android.animation.Animator;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.Transformation;
import android.view.animation.TranslateAnimation;

public class AnimationUtils {

    public static void expand(final View v, long duration) {
        v.measure(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        final int targtetHeight = v.getMeasuredHeight();

        v.getLayoutParams().height = 0;
        v.setVisibility(View.VISIBLE);
        Animation a = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                v.getLayoutParams().height = interpolatedTime == 1
                        ? ViewGroup.LayoutParams.WRAP_CONTENT
                        : (int) (targtetHeight * interpolatedTime);
                v.requestLayout();
            }

            @Override
            public boolean willChangeBounds() {
                return true;
            }
        };

        //a.setDuration((int) (targtetHeight / v.getContext().getResources().getDisplayMetrics().density));
        a.setDuration(duration);
        v.startAnimation(a);
    }

    public static void collapse(final View v, long duration) {
        final int initialHeight = v.getMeasuredHeight();

        Animation a = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                if (interpolatedTime == 1) {
                    v.setVisibility(View.GONE);
                } else {
                    v.getLayoutParams().height = initialHeight - (int) (initialHeight * interpolatedTime);
                    v.requestLayout();
                }
            }

            @Override
            public boolean willChangeBounds() {
                return true;
            }
        };

        //a.setDuration((int) (initialHeight / v.getContext().getResources().getDisplayMetrics().density));
        a.setDuration(duration);
        v.startAnimation(a);
    }

    public static void leftToRightAnimationVisible(View v, long duration) {
        TranslateAnimation anim = new TranslateAnimation(-100f, 0f, 0f, 0f);  // might need to review the docs
        anim.setDuration(duration); // set how long you want the animation

        v.setAnimation(anim);
        v.setVisibility(View.VISIBLE);

        /*v.setAlpha(0f);
        v.setVisibility(View.VISIBLE);

        // Animate the content view to 100% opacity, and clear any animation
        // listener set on the view.
        v.animate()
                .alpha(1f)
                .setDuration(duration)
                .setListener(null);*/
    }

    public static void rightToLeftAnimationGone(final View v, long duration) {
        TranslateAnimation anim = new TranslateAnimation(0f, -100f, 0f, 0f);  // might need to review the docs
        anim.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
                v.setVisibility(View.GONE);
            }

            @Override
            public void onAnimationEnd(Animation animation) {

            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });
        anim.setDuration(duration);

        v.startAnimation(anim);

    }

    public static void hideButton(final View view) {
        view.animate().translationY(view.getHeight()).alpha(0.0f).setDuration(400).setListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                view.setVisibility(View.INVISIBLE);
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
    }

    public static void visibleButton(final View view) {
        view.animate().translationY(0).alpha(1.0f).setDuration(400).setListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
                view.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
    }

}
