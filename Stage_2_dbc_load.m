clear;
clc;

dbcFile = ...
"C:\Users\sitam\OneDrive\Projects\CAN Bus Project\MotorsportCAN.dbc";

db = canDatabase(dbcFile);

disp(db.Messages)