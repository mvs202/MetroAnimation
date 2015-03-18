// Data Animation Generator, v2
// Written by Michael Schade, (c)2013 
import java.util.*;  
import java.text.SimpleDateFormat;
// get data from http://mvjantzen.com/cabi/cabixmlbuild.php
// add White House manually: 38.896494, -77.038947, 31210
String[] stopName;
float[] lats;
float[] lngs;
String[] stations;
Boolean[] stationInUse;
Boolean[] stationInFocus;
//ArrayList<Integer>[] recentRegRides = (ArrayList<Integer>[])new ArrayList[stopName.length];
float minLng;  // left
float maxLng;  // right
float minLat;  // bottom
float maxLat;  // top
int swidth;
int sheight;
int tickCount = 0;
int histogramWidth;
String movieTitle; 
int[] groupA;   
int[] groupB; 
int[] into; 
int[] within; 
int[] outof; 
PImage bg;
color c1;  
color c1t;
color c2;  
color c2t;
List<CaBiTrip> validTrips;
color enteringColor = color(109, 197, 58, 153);   
color stayingColor = color(246, 93, 85, 153);
color leavingColor = color(8, 170, 245, 153);  
color enteringColorSolid;   
color stayingColorSolid;   
color leavingColorSolid;   
int maxBusiest = 0;
int[][] tripRiders;
int[][] tripRidersCas;
int mostRidersPerStation;
int maxRidersPerRoute = 0; 
float[][] tripControlX;
float[][] tripControlY;
  int ridersLeaving;
  int ridersStaying;
  int ridersEntering;
  float[] stationX;
  float[] stationY;   
Boolean lightmap = true;  // map is lightcolored, not dark (font color depends on this)
int[][] balances; 
int[] balanceSum; 
int[] usageDiff; 
int[] totalEntries; 
int[] totalExits; 
/*
IntList[] recentEntries; 
IntList[] recentExits; 
*/
String dataTitle;
String subTitle;
int SECONDSperDAY = 60*60*24;
ArrayList[][] tripPath;

class Point2D {
  float x, y;
  Point2D(float x, float y) {
    this.x = x;
    this.y = y; 
    }
  }

class Segment {
  Point2D point;
  float distance;  
  float portion;  // 0 to 1: how far this point is to the end point
  Segment(Point2D p, float d) {
    this.point = p;
    this.distance = d;
    }
  }

public class CaBiTrip { 
  public int bikeoutStation;
  public int bikeinStation;
  public int bikeoutTime; 
  public int bikeinTime;
  public int trips;
  public Boolean acrossMidnight;  // set to true if you want cross-midnight trips to be shown both in the morning and at night
  public Calendar bikeoutDayTime;
  public Calendar bikeinDayTime; 
  public CaBiTrip(int stationA, int stationB, String timeA, String timeB, String people) { 
    bikeoutStation = stationA;
    bikeinStation = stationB;
    bikeoutTime = parseInt(timeA);
    bikeinTime = parseInt(timeB); 
    trips = parseInt(people);
    //println(bikeoutTime+", "+bikeinTime);
    }     
  }
  
public class cabiCircle implements Comparable<cabiCircle> { 
  public float x, y;
  public int radius;  
  public Boolean selected;
  public cabiCircle(float X, float Y, int R, Boolean B) {
    x = X;
    y = Y;
    radius = R;
    selected = B;
    }
  @Override public int compareTo(cabiCircle that) {  // so that "sort" function will work
    if (this.radius < that.radius) return -1;
    if (this.radius > that.radius) return 1;
    return 0;
    }     
  } 

void initSystem(String system) {
  String lines[] = loadStrings(system); 
  stopName = new String[lines.length];  
  lats = new float[lines.length];      
  lngs = new float[lines.length];       
  stations = new String[lines.length];    
  usageDiff = new int[lines.length];  
  totalEntries = new int[lines.length];   
  totalExits = new int[lines.length];  
  for (int i = 0; i < lines.length; i++) {   
    String[] fields = split(lines[i], ",");
    stopName[i] = fields[0];
    lats[i] = parseFloat(fields[1]);
    lngs[i] = parseFloat(fields[2]);
    stations[i] = fields[3]; 
    usageDiff[i] = 0; 
    totalEntries[i] = 0; 
    totalExits[i] = 0; 
    } 
  stationInUse = new Boolean[lines.length];
  stationInFocus = new Boolean[lines.length];  
  } 
/*
Calendar xxx(int stationA) { 
  for all
    visited[i] = false;
  visited[stationA] = true; 
  path[stationA] = null;
  path = null;
  edgelist = null;
  add stationA's edges to edgelist
  loop { 
    for all edgelist i
      visited[i] = true; 
      path[i] = edgelist[i].path + i;
      add i's edges to edgelist
    }
  }

Calendar exploreOptions(String stationA, String stationB) {
  for i each vector 
    if (!visited[i]) {
      visited[i] = true;
      visited[i] = true;
      exploreOptions(stationA);
      }
  }

Calendar directPath(String stationA, String stationB) {
  ArrayList p = new ArrayList(); 
  for i each line 
  }
  
Calendar transferPath(String stationA, String stationB) {
  p1 =  
  }

Calendar metroPath(String stationA, String stationB) {
  p = directPath(String stationA, String stationB);
  if p.length() == 0)
    p = transferPath(String stationA, String stationB);
  }

void drawMidPoint(int origin, int destination, float scale, int radius) { 
  Segment[] path;
  path = paths[origin][destination];
  ellipse(x, y, radius, radius);
  }
  */
  
Calendar stringToCalendar(String time) {
  String[] daytime = split(time, " ");
  String[] mdy = split(daytime[0], "/");  
  String[] hm = split(daytime[1], ":");
  return new GregorianCalendar(parseInt(mdy[2]), parseInt(mdy[0]) - 1, parseInt(mdy[1]), parseInt(hm[0]), parseInt(hm[1]), 0);
  }

float toY(float lat) {
  return sheight - sheight*(lat - minLat)/(maxLat - minLat);
  }

float toX(float lng) {
  return swidth*(lng - minLng)/(maxLng - minLng);
  } 

void drawStations(int f) { 
  // draw all the stations
  int radius;
  int traffic;
  color fillColor; 
    strokeWeight(3);
    fill(241, 89, 42);
    int busiestStation = 0;
    int[] tripsToFromStation = new int[stopName.length];
    for (int i = 0; i < stopName.length; i++) {
      tripsToFromStation[i] = 0;
      for (int j = 0; j < stopName.length; j++) {
        traffic = tripRiders[i][j] + tripRidersCas[i][j] + tripRiders[j][i] + tripRidersCas[j][i];
        tripsToFromStation[i] += traffic;
        }
      busiestStation = max(busiestStation, tripsToFromStation[i]);
      }
    for (int rs = 0; rs < stopName.length; rs++) { 
      if (stationInFocus[rs]) 
        radius = 7;
      else
        radius = 6;
      if (stationInUse[rs]) {
        stroke(0, 255);
        fill(255, 255); 
        }
      else {  
        stroke(0, 159);
        fill(255, 159); 
        }
      ellipse(toX(lngs[rs]), toY(lats[rs]), radius, radius);
      } 
    maxBusiest = max(maxBusiest, busiestStation);
  }    

void drawKey(String timestamp) {
  float scale = 32;
  textSize(12); 
  if (lightmap)
    fill(0,0,0);
  else
    fill(255,255,255);
  textAlign(LEFT, BOTTOM);
  pushMatrix();  
  translate(swidth - 2, sheight - 4);
  rotate(-HALF_PI);
  text("©Mobility Lab", 0, 0);
  popMatrix();   
  fill(255,0,0); 
  int TitleY;  
    TitleY = sheight - 37;
  textAlign(RIGHT); 
  textSize(18);  
  strokeText(movieTitle, swidth - 15, sheight - 73); 
  strokeText(subTitle, swidth - 15, sheight - 55); 
  strokeText(dataTitle, swidth - 15, sheight - 37); 
  strokeText(timestamp, swidth - 15, sheight - 9);
  strokeWeight(1);
  int midpoint;
  int midpoint2;
  int baseline = sheight - 19;
  int leftEdge = 8;
  }

String toHHMM(int minutes) {
  int hours = floor(minutes/60);
  minutes -= hours*60; 
  hours = hours % 24; 
  String hh, mm, ampm;
  if (hours == 0) {
    hh = "12";
    ampm = "AM";
    }
  else if (hours < 12) { 
    hh = str(hours);
    ampm = "AM";
    }
  else if (hours == 12) { 
    hh = "12";
    ampm = "PM";
    }
  else { 
    hh = str(hours - 12);
    ampm = "PM";
    }
  if (minutes < 10) 
    mm = "0" + str(minutes);
  else
    mm = str(minutes);
  return hh + ":" + mm + ampm;
  } 

void partialBezier(float t0, float t1, float x1, float y1, float bx1, float by1, float bx2, float by2, float x2, float y2) {  
  float u0 = 1.0 - t0;
  float u1 = 1.0 - t1;
  float qxa =  x1*u0*u0 + bx1*2*t0*u0 + bx2*t0*t0;
  float qxb =  x1*u1*u1 + bx1*2*t1*u1 + bx2*t1*t1;
  float qxc = bx1*u0*u0 + bx2*2*t0*u0 +  x2*t0*t0;
  float qxd = bx1*u1*u1 + bx2*2*t1*u1 +  x2*t1*t1;
  float qya =  y1*u0*u0 + by1*2*t0*u0 + by2*t0*t0;
  float qyb =  y1*u1*u1 + by1*2*t1*u1 + by2*t1*t1;
  float qyc = by1*u0*u0 + by2*2*t0*u0 +  y2*t0*t0;
  float qyd = by1*u1*u1 + by2*2*t1*u1 +  y2*t1*t1;
  float xa = qxa*u0 + qxc*t0;
  float xb = qxa*u1 + qxc*t1;
  float xc = qxb*u0 + qxd*t0;
  float xd = qxb*u1 + qxd*t1;
  float ya = qya*u0 + qyc*t0;
  float yb = qya*u1 + qyc*t1;
  float yc = qyb*u0 + qyd*t0;
  float yd = qyb*u1 + qyd*t1; 
  bezier(xa, ya, xb, yb, xc, yc, xd, yd); 
  }
  
void gradientBezier(float x1, float y1, float midx, float midy, float x2, float y2) {  
  stroke(255,0,0,40); partialBezier(0.0, 0.0833, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(250,0,0,48); partialBezier(0.0833, 0.1667, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(245,0,0,56); partialBezier(0.1667, 0.25, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(240,0,0,64); partialBezier(0.25, 0.3333, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(235,0,0,72); partialBezier(0.3333, 0.4167, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(230,0,0,80); partialBezier(0.4167, 0.5, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(225,0,0,88); partialBezier(0.5, 0.5833, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(220,0,0,96); partialBezier(0.5833, 0.6667, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(215,0,0,104); partialBezier(0.6667, 0.75, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(210,0,0,112); partialBezier(0.75, 0.8333, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(205,0,0,120); partialBezier(0.8333, 0.9167, x1, y1, midx,midy,midx,midy, x2, y2);
  stroke(200,0,0,128); partialBezier(0.9167, 1.0, x1, y1, midx,midy,midx,midy, x2, y2);
  }
  
void strokeText(String message, int x, int y) { 
  if (lightmap) {
    fill(255); 
    text(message, x-2, y); 
    text(message, x, y-2); 
    text(message, x+2, y); 
    text(message, x, y+2); 
    fill(0); 
    text(message, x, y); 
    }
  else {
    fill(0,0,0, 128);  
    text(message, x+2, y+2);  
    fill(255); 
    text(message, x, y); 
    }
  }  

void setBoundary(String background, float south, float west, float north, float east, int w, int h, List<String> validStations, String s) {  
  bg = loadImage(background); 
  minLng = west;  // left
  maxLng = east;  // right
  minLat = south;  // bottom
  maxLat = north;   // top
  swidth = w;
  sheight = h; 
  for (int i = 0; i < stations.length; i++) 
    stationInFocus[i] = validStations.contains(stations[i]);
  movieTitle = s; 
  }

void setDatasource(String csvFile) {
  String trips[];
  int stationA;
  int stationB;
  String outId;
  String inId;
  trips = loadStrings(csvFile);
  int newCount = 0;
  for (int t = 1; t < trips.length; t++) {
    String[] cols = split(trips[t], ",");  // start station, start min, end station, end min, people
    stationA = 0;
    stationB = 0;
    outId = cols[0];
    inId = cols[2];
    while (stationA < stopName.length && !stations[stationA].equals(outId)) stationA++;
    while (stationB < stopName.length && !stations[stationB].equals(inId)) stationB++;
    if (stationA >= stopName.length || stationB >= stopName.length)
      println("ERROR: BAD STATION: " + trips[t]);
    else if ((stationInFocus[stationA] || stationInFocus[stationB])) {
    //else if (outId.equals("A03") || inId.equals("A03")) {
      validTrips.add(new CaBiTrip(stationA, stationB, cols[1], cols[3], cols[4]));
      newCount++;
      }
    if (outId.equals("A03") && inId.equals("C06"))
      println(trips[t]);
    }
  println(newCount + " trips added from " + csvFile);
  }
  
List<String> all() {
  List<String> list = new ArrayList<String>(stations.length); 
  for (int i = 0; i < stations.length; i++) 
    list.add(stations[i]);  
  return list;
  }

color blend(color A, color B, float factor) {
  // factor = 0.0: all A
  // factor = 0.5: half A + half B
  // factor = 1.0: all B
  return color(red(A) + round(factor*(red(B) - red(A))), 
               green(A) + round(factor*(green(B) - green(A))), 
               blue(A) + round(factor*(blue(B) - blue(A))), 
               alpha(A) + round(factor*(alpha(B) - alpha(A))));   
  } 
  
void drawRoutes() {
  // draw all of the bezier curves, behind the other objects 
  float midx, midy;
  int totalRiders;
  noFill();  
  for (int i = 0; i < stations.length; i++) {
    for (int j = 0; j < stations.length; j++) {
      if (i != j)  { 
        midx = tripControlX[i][j];
        midy = tripControlY[i][j];
        totalRiders = tripRiders[i][j] + tripRidersCas[i][j];
        if (totalRiders > 0 && mostRidersPerStation > 0) {   
          strokeWeight(totalRiders); 
          stroke(blend(c1t, c2t, (float)tripRidersCas[i][j]/totalRiders));   
          bezier(stationX[i], stationY[i], midx,midy,midx,midy, stationX[j], stationY[j]); 
          } 
        }
      }
    }
  } 
  
void checkStations(int timeStart, int timeEnd) {  
  textAlign(CENTER, CENTER);
  textSize(15);
  stroke(255, 235, 80, 191);  fill(255, 20, 80, 127); 
  rect(10, sheight - 65, 140, 15, 5);
  stroke(166, 235, 166, 191); fill(166, 20, 166, 127); 
  rect(10, sheight - 45, 140, 15, 5);
  stroke(80, 235, 255, 191);  fill(80, 20, 255, 127); 
  rect(10, sheight - 25, 140, 15, 5);
  fill(255);
  text("MOSTLY ENTRIES", 80, sheight - 59);
  text("BALANCED", 80, sheight - 39);
  text("MOSTLY EXITS", 80, sheight - 19);
  CaBiTrip trip;
  float midx, midy;
  int outTime, inTime;
  int radius;
  int unbalancedness; 
  int[] recentEntries = new int[stopName.length];  
  int[] recentExits = new int[stopName.length];  
  for (int i = 0; i < stopName.length; i++) {
    recentEntries[i] = 0;
    recentExits[i] = 0;
    }
  strokeWeight(2);  
  fill(20, 238, 240, 85);  
  stroke(255, 255, 255, 85);  
  for (int t = 0; t < validTrips.size(); t++) { 
    trip = validTrips.get(t);
    outTime = trip.bikeoutTime;
    inTime = trip.bikeinTime; 
    if (outTime >= timeEnd - 60 && outTime < timeEnd)  
      recentEntries[trip.bikeoutStation] += trip.trips;  
    if (inTime >= timeEnd - 60 && inTime < timeEnd) 
      recentExits[trip.bikeinStation] += trip.trips;  
    /*
    if (outTime >= timeStart && outTime < timeEnd)  
      totalEntries[trip.bikeoutStation] += trip.trips;  
    if (inTime >= timeStart && inTime < timeEnd) 
      totalExits[trip.bikeinStation] += trip.trips;  
      */
    }
  fill(255);
  textSize(20);
  for (int rs = 0; rs < usageDiff.length; rs++) {  
    text(stopName[rs].substring(0, 1), toX(lngs[rs]), toY(lats[rs]) - 2);
    }      
  for (int rs = 0; rs < usageDiff.length; rs++) {  
    radius = round(sqrt(recentEntries[rs] + recentExits[rs])/2); 
    if (recentEntries[rs] + recentExits[rs] == 0)
      unbalancedness = 88;
    else
      unbalancedness = round(175*recentEntries[rs]/(recentEntries[rs] + recentExits[rs]));
    stroke(80 + unbalancedness, 235, 255 - unbalancedness, 191); 
    fill(80 + unbalancedness, 20, 255 - unbalancedness, 127);  
    ellipse(toX(lngs[rs]), toY(lats[rs]), radius, radius);
    }      
  }

void drawRiders(int frame, Boolean toplayer) { 
  CaBiTrip trip;
  float midx, midy;
  int outTime, inTime;
  int radius;
  strokeWeight(2); 
  /*
  if (toplayer) {
    fill(240, 208, 20, 255);  
    stroke(255, 255, 255, 255);  
    }
  else {
    fill(20, 238, 240, 85);  
    stroke(255, 255, 255, 85);  
    }
    */
  for (int t = 0; t < validTrips.size(); t++) { 
    trip = validTrips.get(t);
    //if (toplayer == (stations[trip.bikeoutStation].substring(0, 1).equals("N") || stations[trip.bikeinStation].substring(0, 1).equals("N"))) {
      if (amCoreTrip[trip.bikeoutStation][trip.bikeinStation]) {
        fill(175, 255, 73, 85);
        stroke(255, 255, 153, 170); 
        }         
      else if (pmCoreTrip[trip.bikeoutStation][trip.bikeinStation]) {
        fill(255, 175, 73, 85);
        stroke(255, 255, 153, 170); 
        }   
      else { 
        fill(175, 175, 175, 85);
        stroke(215, 215, 215, 170);  
        }
    outTime = trip.bikeoutTime;
    inTime = trip.bikeinTime; 
    if (frame >= outTime - 2 && frame <= inTime + 2) {  
      float scale = (float)(frame -  outTime)/(float)(inTime -  outTime);   
      radius = max(1, round(sqrt(trip.trips))); 
      if (frame <= outTime) {
        radius = max(1, radius - 4*(outTime - frame));  // "4" is arbitrary!
        ellipse(stationX[trip.bikeoutStation], stationY[trip.bikeoutStation], radius, radius);
        }
      else if (frame >= inTime) {
        radius = max(1, radius - 4*(frame - inTime)); 
        ellipse(stationX[trip.bikeinStation], stationY[trip.bikeinStation], radius, radius);
        }
      else {   
        midx = tripControlX[trip.bikeoutStation][trip.bikeinStation];
        midy = tripControlY[trip.bikeoutStation][trip.bikeinStation];
        float x = bezierPoint(stationX[trip.bikeoutStation], midx, midx, stationX[trip.bikeinStation], scale);
        float y = bezierPoint(stationY[trip.bikeoutStation], midy, midy, stationY[trip.bikeinStation], scale); 
        ellipse(x, y, radius, radius);
        //drawMidPoint(trip.bikeoutStation, trip.bikeinStation, scale, radius);
        }
     //   }
      }
    }
  }

void initCurves() {
  stationX = new float[stations.length];
  stationY = new float[stations.length];
  for (int i = 0; i < stations.length; i++) {
    stationX[i] = toX(lngs[i]);
    stationY[i] = toY(lats[i]);
    }
  tripControlX = new float[stations.length][stations.length];
  tripControlY = new float[stations.length][stations.length];
  for (int i = 0; i < stations.length; i++) {
    for (int j = 0; j < stations.length; j++) {
      float dx = stationX[i] - stationX[j];
      float dy = stationY[i] - stationY[j]; 
      float bezierBulge = (float) Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2))/16;  // 16 is arbitrary!
      float theta = (float) (Math.atan2(dy, dx) + Math.PI/2);  // shifted 90 degrees 
      tripControlX[i][j] = (stationX[i] + stationX[j])/2 + bezierBulge*((float) Math.cos(theta));
      tripControlY[i][j] = (stationY[i] + stationY[j])/2 + bezierBulge*((float) Math.sin(theta)); 
      }
    }  
  tripRiders = new int[stations.length][stations.length];
  tripRidersCas = new int[stations.length][stations.length];
  }

void animate24Hours() {  
  int currentUsage;
  int firstFrame = 5*60;  // 5:00 AM
  int lastFrame = (24 + 3)*60 + 30;  // 3:30 AM the next day
  int minutesPerFrame = 1;  // 60 or 240 or whatever
  int[] maxTraffic = new int[stations.length]; 
  int[] totalTraffic = new int[stations.length];
  for (int i = 0; i < stations.length; i++) {
    maxTraffic[i] = 0;
    totalTraffic[i] = 0;
    }
  // do the math in advance for all possible station pairs
  int frameCount = 0;
  Calendar cal = Calendar.getInstance(); 
  String folder = "frames" + cal.get(Calendar.HOUR) + "-" + cal.get(Calendar.MINUTE) + "/";  
  int imageNo = 0;
  initCurves();
  int regRiders;
  int casRiders;
  //
  // draw each frame of the animation
  //
  println("processing " + validTrips.size() + " trips"); 
  println("============================="); 
  for (int frame = firstFrame; frame <= lastFrame; frame += minutesPerFrame) {
    regRiders = 0; casRiders = 0; 
    ridersLeaving = 0; ridersStaying = 0; ridersEntering = 0; 
    // initialize station-pair count to zero
    for (int i = 0; i < stations.length; i++) {
      for (int j = 0; j < stations.length; j++) {
        tripRiders[i][j] = 0; 
        tripRidersCas[i][j] = 0;
        }
      stationInUse[i] = false;
      }
    // count riders for each station-pair
    CaBiTrip trip;
    for (int t = 0; t < validTrips.size(); t++) { // move to drawRoutes?
      trip = validTrips.get(t);
      if (frame > trip.bikeoutTime - 1 && frame < trip.bikeinTime + 1) {
          tripRidersCas[trip.bikeoutStation][trip.bikeinStation]++;
          casRiders++;
        stationInUse[trip.bikeinStation] = true;
        stationInUse[trip.bikeoutStation] = true; 
        }
      }
    background(bg);
    //drawRoutes();
    drawStations(0);  // draw stations 
    drawRiders(frame, false);
    //drawRiders(frame, true);
    if (floor((float)histogramWidth*frame/lastFrame) >= tickCount && tickCount < histogramWidth - 1) { 
      // add a column to the histogram
      groupA[tickCount] = regRiders;
      groupB[tickCount] = casRiders;
      into[tickCount] = ridersEntering;
      within[tickCount] = ridersStaying;
      outof[tickCount] = ridersLeaving;
      tickCount++;  
      println(100*frame/lastFrame + "%"); 
      } 
    frameCount++;
    drawKey(toHHMM(frame)); 
    saveFrame(folder + "image-" + nf(imageNo++, 5) + ".png");  
    for (int i = 0; i < stations.length; i++) {
      currentUsage = 0;
      for (int j = 0; j < stations.length; j++) {
        currentUsage += tripRiders[i][j] + tripRidersCas[i][j];
        }
      totalTraffic[i] += currentUsage;
      maxTraffic[i] = max(maxTraffic[i], currentUsage);
      }
    } 
  for (int i = 0; i < stations.length; i++)  
    if (totalTraffic[i] > 0 && totalTraffic[i]/imageNo > 0)
      println(maxTraffic[i]/(totalTraffic[i]/imageNo) + " (" + maxTraffic[i] + " / " + (totalTraffic[i]/imageNo) + ") " + stopName[i]);
  println("maxBusiest = " + maxBusiest);
  println("maxRidersPerRoute = " + maxRidersPerRoute);
  }

void animateBalancess() {  
  int currentUsage;
  int firstFrame = 5*60;  // 5:00 AM
  int lastFrame = (24 + 3)*60 + 30;  // 4:00 AM the next day
  int minutesPerFrame = 1;  // 60 or 240 or whatever
  int[] maxTraffic = new int[stations.length]; 
  int[] totalTraffic = new int[stations.length];
  for (int i = 0; i < stations.length; i++) {
    maxTraffic[i] = 0;
    totalTraffic[i] = 0;
    }
  // do the math in advance for all possible station pairs
  int frameCount = 0;
  Calendar cal = Calendar.getInstance(); 
  String folder = "frames" + cal.get(Calendar.HOUR) + "-" + cal.get(Calendar.MINUTE) + "/";  
  int imageNo = 0;
  initCurves();
  int regRiders;
  int casRiders;
  //
  // draw each frame of the animation
  //
  println("processing " + validTrips.size() + " trips"); 
  println("============================="); 
  for (int frame = firstFrame; frame <= lastFrame; frame += minutesPerFrame) { 
    // count riders for each station-pair
    CaBiTrip trip; 
    background(bg);
    //drawRoutes();
    //drawStations(0);  // draw stations  
    checkStations(frame, frame + minutesPerFrame);
    if (floor((float)histogramWidth*frame/lastFrame) >= tickCount && tickCount < histogramWidth - 1) {  
      tickCount++;  
      println(100*frame/lastFrame + "%"); 
      } 
    frameCount++;
    drawKey(toHHMM(frame)); 
    saveFrame(folder + "image-" + nf(imageNo++, 5) + ".png");  
    for (int i = 0; i < stations.length; i++) {
      currentUsage = 0;
      for (int j = 0; j < stations.length; j++) {
        currentUsage += tripRiders[i][j] + tripRidersCas[i][j];
        }
      totalTraffic[i] += currentUsage;
      maxTraffic[i] = max(maxTraffic[i], currentUsage);
      }
    } 
  for (int i = 0; i < stations.length; i++)  
    if (totalTraffic[i] > 0 && totalTraffic[i]/imageNo > 0)
      println(maxTraffic[i]/(totalTraffic[i]/imageNo) + " (" + maxTraffic[i] + " / " + (totalTraffic[i]/imageNo) + ") " + stopName[i]);
  println("maxBusiest = " + maxBusiest);
  println("maxRidersPerRoute = " + maxRidersPerRoute);
  }
  
void drawCircle(float x, float y, color dotColor, boolean blended, int radius) {
  if (radius <= 0)
    return;
  int di = radius*2 - 1;  
    PGraphics tempPage = createGraphics(di, di, JAVA2D);
    tempPage.beginDraw();
    tempPage.background(0);
    tempPage.noStroke();
    tempPage.fill(dotColor);  
    tempPage.ellipse(radius, radius, di, di);
    tempPage.endDraw();
    blend(tempPage, 0, 0, di, di, round(x) - radius, round(y) - radius, di, di, ADD); 
  }     

void setColors(color colorA, color colorB) {  
  c1 = colorA;  
  c1t = color(red(colorA), green(colorA), blue(colorA), 102);
  c2 = colorB;  
  c2t = color(red(colorB), green(colorB), blue(colorB), 102);
  } 
 
String IDof(String name) { 
  String[] metroName = {"McLean","Tysons Corner","Greensboro","Spring Hill","Wiehle-Reston East","Navy Yard","Judiciary Square","McPherson Square","Metro Center","Mt Vernon Sq /7th St-Convention Center","U St/African-Amer Civil War Memorial/Cardozo","Shaw-Howard U","Union Station","Congress Heights","Anacostia","Southern Avenue","Eastern Market","Stadium-Armory","Minnesota Ave","Van Ness-UDC","Cleveland Park","Columbia Heights","Georgia Ave-Petworth","Forest Glen","Wheaton","Silver Spring","Fort Totten","Prince George's Plaza","Branch Ave","Benning Road","Capitol Heights","Deanwood","Cheverly","Addison Road-Seat Pleasant","College Park-U of Md","Landover","Glenmont","Largo Town Center","Morgan Boulevard","New York Ave-Florida Ave-Gallaudet U","Huntington","Court House","Twinbrook","Farragut North","Naylor Road","Suitland","Franconia-Springfield","Vienna/Fairfax-GMU","Dunn Loring-Merrifield","West Falls Church-VT/UVA","East Falls Church","Van Dorn Street","Eisenhower Avenue","Virginia Square-GMU","Rosslyn","Tenleytown-AU","Friendship Heights","Bethesda","Grosvenor-Strathmore","White Flint","Medical Center","Shady Grove","King Street","Pentagon City","Crystal City","Ronald Reagan Washington National Airport","Pentagon","Arlington-Cemetery","Foggy Bottom-GWU","Dupont Circle","Woodley Park-Zoo/Adams Morgan","L'Enfant Plaza","Federal Triangle","Archives-Navy Memorial-Penn Quarter","Waterfront-SEU","Gallery Pl-Chinatown","Rhode Island Ave-Brentwood","West Hyattsville","Greenbelt","Capitol South","Ballston-MU","Rockville","Farragut West","Federal Center SW","Potomac Ave","Brookland-CUA","New Carrollton","Takoma","Clarendon","Braddock Road","Smithsonian"};
  String[] metroID = {"N01","N02","N03","N04","N06","F05","B02","C02","A01","E01","E03","E02","B03","F07","F06","F08","D06","D08","D09","A06","A05","E04","E05","B09","B10","B08","B06","E08","F11","G01","G02","D10","D11","G03","E09","D12","B11","G05","G04","B35","C15","K01","A13","A02","F09","F10","J03","K08","K07","K06","K05","J02","C14","K03","C05","A07","A08","A09","A11","A12","A10","A15","C13","C08","C09","C10","C07","C06","C04","A03","A04","D03","D01","F02","F04","B01","B04","E07","E10","D05","K04","A14","C03","D04","D07","B05","D13","B07","K02","C12","D02"};
  int t = 0;
  do { 
    if (metroName[t].equals(name))  
      break; 
    t++;
    } while (t < metroName.length);
  if (t >= metroName.length)
    println("ERROR: " + name);
  return metroID[t]; 
  } 
  
int codeIndex(String name) { 
  if (name.equals("E06")) name = "B06";  // Ft Totten
  if (name.equals("C01")) name = "A01";  // Metro Center
  if (name.equals("F03")) name = "D03";  // L'Enfant
  if (name.equals("F01")) name = "B01";  // Gallery Pl
  for (int i = 0; i < stations.length; i++) { 
    if (stations[i].equals(name))
      return i;
    }
  println("CAN'T MATCH " + name);
  return 0;
  } 
  
int[][] maxLoadCrossed;
Boolean[][] amCoreTrip;
Boolean[][] pmCoreTrip;
  
void getCoreCounts() {  
  int a, b;
  String lines[] = loadStrings("/Users/michael/mvjantzen.com/metro/data/coretrips.csv"); 
  maxLoadCrossed = new int[stopName.length][stopName.length];  
  amCoreTrip = new Boolean[stopName.length][stopName.length];  
  pmCoreTrip = new Boolean[stopName.length][stopName.length];   
  for (int i = 0; i < lines.length; i++) {
    String[] fields = split(lines[i], ",");
    //println(lines[i]);
    if ( !(fields[0].equals("Route 772") || fields[0].equals("Route 606") || fields[0].equals("Dulles International Airport") || fields[0].equals("Innovation Center") || fields[0].equals("Herndon") || fields[0].equals("Reston Town Center"))
      && !(fields[1].equals("Route 772") || fields[1].equals("Route 606") || fields[1].equals("Dulles International Airport") || fields[1].equals("Innovation Center") || fields[1].equals("Herndon") || fields[1].equals("Reston Town Center"))) {
      a = codeIndex(IDof(fields[0]));
      b = codeIndex(IDof(fields[1]));
      maxLoadCrossed[a][b] = parseInt(fields[2]);
      amCoreTrip[a][b] = (parseInt(fields[3]) == 1);
      pmCoreTrip[a][b] = (parseInt(fields[4]) == 1);
      }
    }
  }

void setup() {  
  initSystem("metro.csv");  // list of station names and lat/lng coords
  getCoreCounts();
  lightmap = false;
  validTrips = new ArrayList<CaBiTrip>(1000000);  // guess 2 million records 
  enteringColorSolid = color(red(enteringColor), green(enteringColor), blue(enteringColor), 204);   
  stayingColorSolid = color(red(stayingColor), green(stayingColor), blue(stayingColor), 204);   
  leavingColorSolid = color(red(leavingColor), green(leavingColor), blue(leavingColor), 204);     
  // Pick the background image and set the lat/lng boundaries:
  // configure(background image, S:bottom, W:left, N:top, E:right, width, height);  
  setBoundary("metro800x600dark.png", 38.7712, -77.3891, 39.0912, -76.8404, 800, 600, all(), "Metro Traffic");  
  setDatasource("/Users/michael/mvjantzen.com/metro/data/Oct2014Weekday.csv"); 
  dataTitle = "October 2014 Weekdays"; 
  if (lightmap)
    setColors(color(93,110,182), color(201, 62, 103));  
  else
    setColors(color(254,204,47), color(252, 48, 29));  // yellow, red 
  histogramWidth = 225; 
  groupA = new int[histogramWidth];
  groupB = new int[histogramWidth];
  into = new int[histogramWidth];
  within = new int[histogramWidth];
  outof = new int[histogramWidth];
  size(swidth, sheight, JAVA2D);
  println("============================="); 
    subTitle = "Hourly Entries + Exits";
    //animate24Hours(); 
    animateBalancess();
  println("!!!");
  }

void draw() {   
  }
