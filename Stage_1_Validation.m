%% ============================================================
%  MOTORSPORT CAN BUS PROJECT
%  STAGE 1 - DBC VALIDATION
%
%  Message:
%       ENGINE_DATA
%
%  CAN ID:
%       0x100
%
%  Validation Conditions:
%       Engine Speed        = 10000 rpm
%       Throttle Position   = 80 %
%       Coolant Temperature = 95 degC
%
%  Expected Payload:
%       40 9C C8 87 00 00 00 00
%
% ============================================================

clear;
clc;
close all;

fprintf("============================================\n");
fprintf("     MOTORSPORT CAN BUS - DBC VALIDATION\n");
fprintf("============================================\n\n");


%% ============================================================
% 1. LOAD DBC
% ============================================================

dbcFile = ...
"C:\Users\sitam\OneDrive\Projects\CAN Bus Project\dbc files\MotorsportCAN.dbc";

if ~isfile(dbcFile)
    error("DBC file not found:\n%s", dbcFile);
end

fprintf("PASS - DBC file found\n");

db = canDatabase(dbcFile);

fprintf("PASS - DBC loaded successfully\n\n");


%% ============================================================
% 2. DISPLAY AVAILABLE CAN MESSAGES
% ============================================================

disp("Available CAN Messages:")
disp(db.Messages)

fprintf("\n");


%% ============================================================
% 3. CREATE ENGINE_DATA MESSAGE FROM DBC
% ============================================================

msg = canMessage(db, "ENGINE_DATA");

fprintf("--------------------------------------------\n");
fprintf(" ENGINE_DATA MESSAGE\n");
fprintf("--------------------------------------------\n");

fprintf("CAN ID: 0x%03X\n", msg.ID);
fprintf("DLC:    %d bytes\n\n", msg.DLC);


%% ============================================================
% 4. DEFINE TEST CONDITIONS
% ============================================================

expectedEngineSpeed = 10000;     % rpm
expectedThrottle    = 80;        % %
expectedCoolant     = 95;        % degC

fprintf("Input Engineering Values:\n");
fprintf("Engine Speed        = %.0f rpm\n", expectedEngineSpeed);
fprintf("Throttle Position   = %.1f %%\n", expectedThrottle);
fprintf("Coolant Temperature = %.1f degC\n\n", expectedCoolant);


%% ============================================================
% 5. MANUALLY CALCULATE RAW VALUES
% ============================================================

% Raw = (Physical - Offset) / Factor

rawEngine = ...
    (expectedEngineSpeed - 0) / 0.25;

rawThrottle = ...
    (expectedThrottle - 0) / 0.4;

rawCoolant = ...
    (expectedCoolant - (-40)) / 1;


fprintf("Calculated Raw Values:\n");
fprintf("Engine Speed        = %.0f\n", rawEngine);
fprintf("Throttle Position   = %.0f\n", rawThrottle);
fprintf("Coolant Temperature = %.0f\n\n", rawCoolant);


%% ============================================================
% 6. DEFINE MANUALLY CALCULATED CAN PAYLOAD
% ============================================================

payload = uint8([ ...
    hex2dec('40'), ...
    hex2dec('9C'), ...
    hex2dec('C8'), ...
    hex2dec('87'), ...
    hex2dec('00'), ...
    hex2dec('00'), ...
    hex2dec('00'), ...
    hex2dec('00')]);


%% ============================================================
% 7. ASSIGN PAYLOAD TO CAN MESSAGE
% ============================================================

msg.Data = payload;


%% ============================================================
% 8. DISPLAY RAW CAN FRAME
% ============================================================

fprintf("--------------------------------------------\n");
fprintf(" RAW CAN FRAME\n");
fprintf("--------------------------------------------\n");

fprintf("ID:      0x%03X\n", msg.ID);
fprintf("DLC:     %d\n", msg.DLC);

fprintf("Payload: ");

for i = 1:length(msg.Data)
    fprintf("%02X ", msg.Data(i));
end

fprintf("\n\n");


%% ============================================================
% 9. DECODE SIGNALS USING THE DBC
% ============================================================

fprintf("--------------------------------------------\n");
fprintf(" DBC DECODED SIGNALS\n");
fprintf("--------------------------------------------\n");

% Access the decoded signals associated with the CAN message
decodedEngineSpeed = msg.Signals.EngineSpeed;
decodedThrottle    = msg.Signals.ThrottlePosition;
decodedCoolant     = msg.Signals.CoolantTemperature;


fprintf("Engine Speed        = %.0f rpm\n", ...
    decodedEngineSpeed);

fprintf("Throttle Position   = %.1f %%\n", ...
    decodedThrottle);

fprintf("Coolant Temperature = %.1f degC\n\n", ...
    decodedCoolant);


%% ============================================================
% 10. AUTOMATIC VALIDATION
% ============================================================

tolerance = 1e-6;

enginePass = ...
    abs(decodedEngineSpeed - expectedEngineSpeed) < tolerance;

throttlePass = ...
    abs(decodedThrottle - expectedThrottle) < tolerance;

coolantPass = ...
    abs(decodedCoolant - expectedCoolant) < tolerance;


%% ============================================================
% 11. DISPLAY VALIDATION RESULTS
% ============================================================

fprintf("--------------------------------------------\n");
fprintf(" VALIDATION RESULTS\n");
fprintf("--------------------------------------------\n");

if enginePass
    fprintf("Engine Speed        : PASS\n");
else
    fprintf("Engine Speed        : FAIL\n");
end

if throttlePass
    fprintf("Throttle Position   : PASS\n");
else
    fprintf("Throttle Position   : FAIL\n");
end

if coolantPass
    fprintf("Coolant Temperature : PASS\n");
else
    fprintf("Coolant Temperature : FAIL\n");
end


%% ============================================================
% 12. OVERALL RESULT
% ============================================================

fprintf("\n");

if enginePass && throttlePass && coolantPass

    fprintf("============================================\n");
    fprintf("       OVERALL DBC VALIDATION: PASS\n");
    fprintf("============================================\n");

else

    fprintf("============================================\n");
    fprintf("       OVERALL DBC VALIDATION: FAIL\n");
    fprintf("============================================\n");

end