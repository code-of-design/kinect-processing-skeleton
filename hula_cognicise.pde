/*
Copyright (C) 2014  Thomas Sanchez Lengeling.
 KinectPV2, Kinect for Windows v2 library for processing

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR AsNY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import KinectPV2.KJoint;
import KinectPV2.*; // Kinect Libray.
import ddf.minim.*; // Sounnd Library.

KinectPV2 kinect;  // Kinectデータ変数.
Minim minim;  // Soundデータ変数.
AudioPlayer player;  // Soundデータ変数.

Skeleton [] skeleton; // スケルトンデータ配列.

// Display.
int DISPLAY_WIDTH = 1920; // Kinectの幅解像度.
int DISPLAY_HEIGHT = 1080; // Kinectの高さ解像度.

float DISPLAY_RATE = 0.7; // Displayサイズの調整変数.
float kinect_x;
float kinect_y;

// Font.
PFont noto_sans;

// Color.
color pink = color(247, 202, 201); // PANTONE ROSE QUARTZ.
color blue = color(146, 168, 209); //PANTONE SERENITY.
color white = color(255, 255, 255);

boolean clap = false; // 拍手判定変数.
PVector r, l; // 手ベクトル.
float hand_dist = 0; // 手の距離.

void setup() {
  // Display.
  // size(int(DISPLAY_WIDTH*DISPLAY_RATE), int(DISPLAY_HEIGHT*DISPLAY_RATE), P3D);
  size(displayWidth, displayHeight, P3D);
  kinect_x = (width-int(DISPLAY_WIDTH*DISPLAY_RATE))/2;
  kinect_y = 100;

  // Font.
  noto_sans = createFont("Noto Sans CJK JP", 72, true);
  textFont(noto_sans);

  // Kinect.
  kinect = new KinectPV2(this);
  kinect.enableSkeleton(true);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  kinect.init();

  // Sound.
  minim = new Minim(this);
  player = minim.loadFile("He Mele No Lilo Hula Dance.mp3"); // mp3の読み込み.
  // player.play();  // 再生.
}

void draw() {
  background(blue);

  image(kinect.getColorImage(), kinect_x, kinect_y, int(DISPLAY_WIDTH*DISPLAY_RATE), int(DISPLAY_HEIGHT*DISPLAY_RATE));
  skeleton =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeleton.length; i++) {
    if (skeleton[i].isTracked()) {
      KJoint[] joints = skeleton[i].getJoints();

      drawBody(joints);

      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);

      // 人体データの位置情報を描画する.
      drawBodyPosition(joints[KinectPV2.JointType_HandRight], "HandRight"); // Kinect座標の右手.
      drawBodyPosition(joints[KinectPV2.JointType_HandLeft], "handLeft"); // Kinect座標の左手.
      drawBodyPosition(joints[KinectPV2.JointType_FootRight], "FootRight"); // Kinect座標の右足.
      drawBodyPosition(joints[KinectPV2.JointType_FootLeft], "FootLeft"); // Kinect座標の左足.

      drawHandDist(joints[KinectPV2.JointType_HandRight], joints[KinectPV2.JointType_HandLeft]);
    }
  }

  // UI.
  drawUi();

  // システム情報を描画する.
  textSize(14);
  fill(white);
  pushMatrix();
  translate(kinect_x, 40);
  text("Project: HULA COGNICISE", 0, 24*0);
  text("DisplaySize: "+int(DISPLAY_WIDTH*DISPLAY_RATE)+"*"+int(DISPLAY_HEIGHT*DISPLAY_RATE), 0, 24*1);
  text("FrameRate: "+int(frameRate), 0, 24*2);
  text("HandDistance: "+int(hand_dist), 0, 24*3);
  text("Clap: "+clap, 0, 24*4);
  popMatrix();
}

void drawUi(){
  /*
  noFill();
  stroke(blue);
  strokeWeight(80);
  rect(0, 0, width, height);
  noStroke();
  strokeWeight(1); // 初期値.
  */
  fill(blue);
  noStroke();
  rect(0, 0, width, 160);
  noFill();
}

//Bodyを描画する.
void drawBody(KJoint[] joints) {
  fill(pink);
  stroke(pink);

  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX()*DISPLAY_RATE+kinect_x, joints[jointType].getY()*DISPLAY_RATE+kinect_y, joints[jointType].getZ()*DISPLAY_RATE);
  ellipse(0, 0, 25, 25);
  popMatrix();
}

void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX()*DISPLAY_RATE+kinect_x, joints[jointType1].getY()*DISPLAY_RATE+kinect_y, joints[jointType1].getZ()*DISPLAY_RATE);
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX()*DISPLAY_RATE+kinect_x, joints[jointType1].getY()*DISPLAY_RATE+kinect_y, joints[jointType1].getZ()*DISPLAY_RATE, joints[jointType2].getX()*DISPLAY_RATE+kinect_x, joints[jointType2].getY()*DISPLAY_RATE+kinect_y, joints[jointType2].getZ()*DISPLAY_RATE);
}

void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX()*DISPLAY_RATE+kinect_x, joint.getY()*DISPLAY_RATE+kinect_y, joint.getZ()*DISPLAY_RATE);
  ellipse(0, 0, 70, 70);
  popMatrix();
}

// Bodyの位置情報を描画する.
void drawBodyPosition(KJoint joint, String body_name){
  // background(pink);
  fill(white);
  pushMatrix();
  translate(joint.getX()*DISPLAY_RATE+kinect_x - 20, joint.getY()*DISPLAY_RATE+kinect_y - 100, joint.getZ()*DISPLAY_RATE);
  text(body_name, 0, 0);
  text("X: "+int(joint.getX()*DISPLAY_RATE+kinect_x - 50), 0, 20);
  text("Y: "+int(joint.getY()*DISPLAY_RATE+kinect_y - 50), 0, 20 + 15*1);
  text("Z: "+int(joint.getZ()*DISPLAY_RATE), 0, 20 + 15*2);
  popMatrix();
}

// 手の距離を描画する.
void drawHandDist(KJoint jointR, KJoint jointL){
  r = new PVector(jointR.getX()*DISPLAY_RATE+kinect_x, jointR.getY()*DISPLAY_RATE+kinect_y); // 右手ベクトル.
  l = new PVector(jointL.getX()*DISPLAY_RATE+kinect_x, jointL.getY()*DISPLAY_RATE+kinect_y); // 左手ベクトル.
  float dist_th = 50;

  // 手の距離を測定する.
  hand_dist = PVector.dist(r, l);

  // 手の距離を描画する.
  fill(blue);
  stroke(blue);
  strokeWeight(3);
  line(r.x, r.y, l.x, l.y);

  // 拍手の判定をする.
  if(hand_dist <= dist_th ){
    clap = true;
  }
  else{
    clap = false;
  }
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0); // Green.
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0); // Red.
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255); // Blue.
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255); // White.
    break;
  }
}

// Sound停止.
void stop(){
  player.close();
  minim.stop();
  super.stop();
}
