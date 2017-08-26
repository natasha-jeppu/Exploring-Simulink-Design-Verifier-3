% This program converts the Mode Transition table to NuSMV code
% NuSMV  is available at http://nusmv.fbk.eu/
% NuSMV: a new symbolic model checker

% Copyright Natasha Jeppu, natasha.jeppu@gmail.com
% http://www.mathworks.com/matlabcentral/profile/authors/5987424-natasha-jeppu

clear all
clc

% Offset of the modes

% Example 01
offset=[0
0
0
0
0
0
6
6
8
8
8
];

% Example 02
% offset=[0
% 0
% 0
% 0
% 0
% 5
% 5
% 5
% 5
% 9
% 9
% 11
% 11];

offset = [offset;-1]; % This is required because of the logic looks at the next cell. Leave it as such.

% Define the trigger variables here

% Example 02
% trig={'T1'
% 'T2'
% 'T3'
% 'T4'
% 'T5'
% 'T6'
% };

% Example 01
trig={'tAPFAIL'
'tAP'
'tALTCPDN'
'tALTCAP'
'tALT'
'tALTS'
'tSPD'
'tVS'
};

% Define the mode variable names here

% Example 02
% mode={'M1'
%       'M2'
%       'M3'
%       'M4'};
  
% Example 01
mode={'Vm'
      'APm'
      'ASm'};
% Define the state variable names here

% Example 02
% state={'M1_S1'
% 'M1_S2'
% 'M1_S3'
% 'M1_S4'
% 'M1_S5'
% 'M2_S1'
% 'M2_S2'
% 'M2_S3'
% 'M2_S4'
% 'M3_S1'
% 'M3_S2'
% 'M4_S1'
% 'M4_S2'
% };

% Example 01
state={'DIS'
'PAH'
'SPD_HOLD'
'VS'
'ALT_HOLD'
'ALTS_CAP'
'APON'
'APOFF'
'ALTSOFF'
'ALTSARM'
'ALTSCAP'
};

% Define the condition variable names here
% Example 02
% cond={'C1'
%     'C2'
%     'C3'
%     'C4'
%     'C5'
%     'C6'
% };

% Example 01
cond={'C1'
    'C2'
    'C3'
    'C4'
    'C5'
};

% Transition matrix
% Example 01
T=[     0     2     0     0     0     0     0     0
     1     1     0     6     5     0     3     4
     1     1     0     6     5     0     2     4
     1     1     0     6     5     0     3     2
     1     1     0     0     2     0     3     4
     1     1     5     0     5     0     0     0
     2     2     0     0     0     0     0     0
     0     1     0     0     0     0     0     0
     0     0     0     0     0     2     0     0
     1     1     0     3     1     1     0     0
     1     1     1     0     1     0     0     0
];

% Example 02
% T=[0	2	0	0	0	0
% 1	20304	304	3	0	3
% 1	2	2	4	0	0
% 1	2	2	5	0	0
% 1	0	0	2	0	0
% 0	2	0	0	0	0
% 1	0	0	2	0	0
% 1	0	0	4	0	0
% 1	0	0	2	0	0
% 0	2	0	0	2	0
% 1	0	0	0	1	0
% 0	2	0	0	2	0
% 1	0	0	0	1	0
% ];



%Condition Matrix
% Example 01
C=[
     0     1     0     0     0     0     0     0
     2     2     0     0     5     0     3     4
     2     2     0     0     5     0     0     4
     2     2     0     0     5     0     3     0
     2     2     0     0     0     0     3     4
     2     2     0     0     5     0     0     0
     0     0     0     0     0     0     0     0
     0     1     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
     2     2     0     0     5     0     0     0
     2     2     0     0     5     0     0     0
];

% Example 02
% C=[0	3	0	0	0	0
% 2	40506	506	1	0	4
% 2	1	4	1	0	0
% 2	1	4	1	0	0
% 2	0	0	1	0	0
% 0	3	0	0	0	0
% 2	0	0	1	0	0
% 2	0	0	1	0	0
% 2	0	0	1	0	0
% 0	3	0	0	5	0
% 2	0	0	0	1	0
% 0	3	0	0	6	0
% 2	0	0	0	1	0
% ];


ns = size(T,1);
nt=length(trig);
nc=size(cond,1);

ic = 0;
imode = 1;
delete test.smv
diary test.smv
disp ('MODULE main');
disp ('VAR');

for t = 1:nt
    disp ([trig{t} ':boolean;' ]);
end
disp('  ');

for i=1:nc %take number of conditions
    disp ([cond{i} ':boolean;' ]);
end
disp('  ');   
disp('TRIG:{0');
for t=1:nt
    disp([',' num2str(t)]);
end
disp('};');

imode=2;
disp([mode{1} ':{']);
for i=1:ns-1
   if offset(i)~=offset(i+1)
       disp([state{i} ' };']);
       disp([mode{imode} ':{']);
       imode=imode+1;    
   else
       disp([state{i} ',']);
   end
end
if offset(ns-1)==offset(ns)
    disp([state{ns} ' };']);
else
    disp([mode{imode} ':{']);
    disp([state{ns} ' };']);
end
disp('   ');
disp ('ASSIGN');
imode = 2;
disp(['init(' mode{1} ') :=' state{1} ';']);
for i=1:ns-1
    if offset(i)~=offset(i+1)
        disp(['init(' mode{imode} ') :=' state{i+1} ';']);
        imode=imode+1;
    end
end
disp('   ');
disp('-- Add additonal conditions to set the triggers');
disp ('TRIG := case');
for t = 1:nt
    disp ([trig{t} ' = TRUE :' num2str(t) ';' ]);
end
disp ('TRUE :0;');
disp ('esac;');
disp('  ');
imode=1;
disp(['next(' mode{imode} '):=case']);
for i = 1:ns  % no of states
    for j = 1:nt   % no of triggers
        if T(i,j) ~= 0
            if T(i,j) < 100   % only one 
                if C(i,j) == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{C(i,j)}]; % only one condition
                    condisp = cond{C(i,j)};
                end
                ic=ic+1;
                if(~strcmp(state{i},state{T(i,j)+offset(i)}))         
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{T(i,j)+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{T(i,j)+offset(i)} ';']);
                else
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{T(i,j)+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{T(i,j)+offset(i)} ';']); 
                end
                
            elseif T(i,j) >= 100  && T(i,j) <= 9999% there are two transitions
                a=T(i,j)-fix(T(i,j)/100)*100;
                b=C(i,j)-fix(C(i,j)/100)*100;
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end 
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end
                
                a=fix(T(i,j)/100);  % get the second transition
                b=fix(C(i,j)/100);
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end 
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end  
                
                
               elseif  T(i,j) > 9999% there are three transitions
                    
                a=T(i,j)-fix(T(i,j)/100)*100;
                b=C(i,j)-fix(C(i,j)/100)*100;
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end  
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end
                    
                a=T(i,j)-fix(T(i,j)/10000)*10000;a=fix(a/100);  % gets the second
                b=C(i,j)-fix(C(i,j)/10000)*10000;b=fix(b/100);
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end  
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end
                
                a=fix(T(i,j)/10000);  % get the second transition
                b=fix(C(i,j)/10000);
                if b == 0  % there is no condition
                    condt = ' ';
                    condisp = ' [No Condition required] ';
                else
                    condt = [' & ' cond{b}]; % only one condition
                    condisp = cond{b};
                end  
                ic = ic+1;
                if(strcmp(state{i},state{a+offset(i)}))
                   disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN remain in ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                   disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                else
                    disp(['--' num2str(ic) ') If in State ' state{i} ' AND Trigger ' trig{j} ' occurs THEN transit to ' state{a+offset(i)} ' if condition ' condisp ' Is TRUE']);
                    disp([mode{imode} ' = ' state{i} ' & (TRIG = ' num2str(j) ')' condt ' : ' state{a+offset(i)} ';']);
                end
                
            end
        end
    end
    if (offset(i) ~= offset(i+1))
        disp (['TRUE :' mode{imode} ';']);
        disp('esac;');
        disp('  ');
        imode=imode+1;
        if i~=ns
            disp(['next(' mode{imode} '):=case']);
        end
    end
end

disp('  ');
disp('-- ==============');
disp('  ')
disp('-- Put LTLSPEC here - Example');
disp('-- LTLSPEC G (( M1 = M1_S5 ) -> M2 = M2_S2)');
diary off