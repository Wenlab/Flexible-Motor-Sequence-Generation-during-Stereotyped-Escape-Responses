function [timeElapsed, DLPstate] = read_data_from_yaml(fName)
% read yaml as txt file
fid = fopen(fName);
tline = fgets(fid);
DLPstate = [];
sElapsed = [];
msRemElapsed = [];
lineIdx = 1;
while tline ~= -1
    if isField(tline)
       fieldName = getField(tline);
       switch fieldName
           case 'DLPIsOn'
                val =getVal(tline);
                DLPstate = cat(1,DLPstate,val);
           case 'sElapsed'
               val =getVal(tline);
                sElapsed = cat(1,sElapsed,val);
           case 'msRemElapsed'
                val =getVal(tline);
                msRemElapsed = cat(1,msRemElapsed,val);      
        end
    end
    tline = fgets(fid);
    lineIdx = lineIdx + 1;
end
timeElapsed = sElapsed + msRemElapsed/1000; % seconds

end


function ret=isField(str)
%This function checks to see if this is a field in the form of
% `field:`
%
% If no field is present it returns 0
% If a field is present it returns 1
if regexp(str,'^[ \t\r\n\v\f]*[a-z,A-Z]*:[ \t\r\n\v\f]')
    ret=1;
else
    ret=0;
end
end

function fieldName=getField(str)
q=textscan(str,'%q','Delimiter',':');
fieldName=q{1}{1};
end

function val =getVal(str)
% Functio to parse an integer value

if isFieldWithValue(str)
    tmp=textscan(str,'%s','Delimiter',':');
    val=str2num(tmp{1}{2});
else
    val=NaN;
end
end

function ret=isFieldWithValue(str)
%This function checks to see if this is a field in the form of
% `field: "[349, 345, balh balh`
%
% If no returns 0
% If yes returns 1

if regexp(str,'^[ \t\r\n\v\f]*[a-z,A-Z]*:[ \t\r\n\v\f]*[^ \t\r\n\v\f]+')
    ret=1;
else
    ret=0;
end

end
