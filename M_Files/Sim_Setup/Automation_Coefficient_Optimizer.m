%automate simulations and solve for coefficients yielding best results
%Sliding Mode VLC Test
%stop simulation command:
%set_param(gcs, 'SimulationCommand', 'stop')

%prevent warnings from showing in command window
warning('off','all');

Simulation_Count = 0; %Counts the simulation iteration number

gdp = 0;   %Number of actual saved control gain points (initialized to zero)
nsp = 50;  %Max number of saved control gain points
stop_time = 5.501;   %simulation run time (HAS TO BE CHANGED HERE AND ALSO IN MODEL FILE)
min_rms_YE = repmat(100, 1, nsp);
min_rms_YE_X = repmat(100, 1, nsp);
Lat_Accel_Err_Gain_Lowest = repmat(100, 1, nsp);
Lat_Accel_Err_Gain_Lowest_X = repmat(100, 1, nsp);
Slip_Err_P_Gain_Lowest = repmat(100, 1, nsp);
Slip_Err_P_Gain_Lowest_X = repmat(100, 1, nsp);
Yaw_Err_P_Gain_Lowest = repmat(100, 1, nsp);
Yaw_Err_P_Gain_Lowest_X = repmat(100, 1, nsp);
Yaw_Ctrl_Gain_Lowest = repmat(100, 1, nsp);
Yaw_Ctrl_Gain_X = repmat(100, 1, nsp);

VMC_Vx = repmat(100, int32(stop_time*1000), nsp);
VMC_Vy = repmat(100, int32(stop_time*1000), nsp);
VMC_r  = repmat(100, int32(stop_time*1000), nsp);
VMC_YE = repmat(100, stop_time*1000, nsp);

%Set up sim values
addpath('M_Files/Sim_Setup');
run('AWD_Test_W_FUZ_Control.m');

%Add path for sim files
addpath('All_Combined');
addpath('Fuzzy_Controller_Files');


sim_pts = 60;
sim_pts_la = 10;
%for cntr3=sim_pts:-1:1
    %for cntr2=sim_pts:-1:1
       %for cntr1=sim_pts:-1:1
            for cntr=1:sim_pts
                %update workspace
                %whos
                
                
                %make edits to sim values
                Lat_Accel_Err_Gain = ??
                Slip_Err_P_Gain = 154;%35 + 15*cntr
                Yaw_Err_P_Gain = 3^(-10+cntr/3)
                Yaw_Ctrl_Gain = ??
                %simulate and collect data
                Simulation_Count = Simulation_Count + 1
                %assignin('base', 'Simulation_Count', Simulation_Count)
                sim('All_Combined\AWD_EV_MODEL_rev2.mdl')%,'CaptureErrors', 'on')
                
                %generate yaw error rms info
                yaw_rms_err(cntr) = rms(VMC(:,15));
                Yaw_Err_P_Gain_Saved(cntr) = Yaw_Err_P_Gain;
                %analyze data and make decision
                min_rms_YE_new = rms(VMC(:,15));  %Check min rms Yaw error
                YE_Saved(Simulation_Count) = min_rms_YE_new
                min_rms_YE
                if  VMC(4000,16) > 15 ...            %make sure velocity is greater than 5m/s by 5s
                    && max(VMC(1:5400,16)) >  VMC(5500,16)%...     %make sure Vy lower than 1m/s the entire time.
                    %		&& max(VMC(:,18)) < 0.08;    % make sure yaw rate does not exceed 0.08rad(4.5deg)/s
                    for num = 1:(nsp-1)
                        if min_rms_YE_new < min_rms_YE(num);
                            for s = num:nsp
                                min_rms_YE_X(1,s+1) = min_rms_YE(1,s);
                                Lat_Accel_Err_Gain_Lowest_X(1,s+1) = Lat_Accel_Err_Gain_Lowest(1,s);
                                Slip_Err_P_Gain_Lowest_X(1,s+1) = Slip_Err_P_Gain_Lowest(1,s);
                                Yaw_Err_P_Gain_Lowest_X(1,s+1) = Yaw_Err_P_Gain_Lowest(1,s);
                                Yaw_Ctrl_Gain_X(1,s+1) = Yaw_Ctrl_Gain_Lowest(1,s);
                                
                                VMC_Vx_X(:,s+1) = VMC_Vx(:,s);
                                VMC_Vy_X(:,s+1) = VMC_Vy(:,s);
                                VMC_r_X (:,s+1) = VMC_r (:,s);
                                VMC_YE_X(:,s+1) = VMC_YE(:,s);
                            end
                            %Place value in 1st slot of dummy (X) arrays
                            min_rms_YE_X(1,num) = min_rms_YE_new;
                            Lat_Accel_Err_Gain_Lowest_X(1,num) = Lat_Accel_Err_Gain;
                            Slip_Err_P_Gain_Lowest_X(1,num) = Slip_Err_P_Gain;
                            Yaw_Err_P_Gain_Lowest_X(1,num) = Yaw_Err_P_Gain;
                            Yaw_Ctrl_Gain_X(1,num) = Yaw_Ctrl_Gain;
                            
                            VMC_Vx_X(:,num) = VMC(:,16);
                            VMC_Vy_X(:,num) = VMC(:,17);
                            VMC_r_X (:,num) = VMC(:,18);
                            VMC_YE_X(:,num) = VMC(:,15);
                            
                            %set newly constructed arrays to variable
                            min_rms_YE = min_rms_YE_X;
                            Lat_Accel_Err_Gain_Lowest = Lat_Accel_Err_Gain_Lowest_X;
                            Slip_Err_P_Gain_Lowest = Slip_Err_P_Gain_Lowest_X;
                            Yaw_Err_P_Gain_Lowest = Yaw_Err_P_Gain_Lowest_X;
                            Yaw_Ctrl_Gain_Lowest = Yaw_Ctrl_Gain_X;
                            
                            Gains(1,:) = Lat_Accel_Err_Gain_Lowest_X;
                            Gains(2,:) = Slip_Err_P_Gain_Lowest_X;
                            Gains(3,:) = Yaw_Err_P_Gain_Lowest_X;
                            Gains(4,:) = Yaw_Ctrl_Gain_X;
                            
                            VMC_Vx = VMC_Vx_X;
                            VMC_Vy = VMC_Vy_X;
                            VMC_r  = VMC_r_X;
                            VMC_YE = VMC_YE_X;
                            
                            gdp = gdp + 1;
                            
                            break
                        else
                            dummy=1;
                        end
                    end
                    
                else
                    dummy=1;
                    
                end
            end
        %end
    %end
%end

%save workspace to file
Filename_mat = sprintf('Sliding_Mode_Control_CSA_w50kcnrstiffns_Test_%s.mat', datestr(now,'mm-dd-yyyy_HH-MM'));
save(Filename_mat);



figure
hold on
scatter(Yaw_Err_P_Gain_Saved, yaw_rms_err)

%Save figure
Filename_yrmserr_v_ygain_fig = sprintf('Sliding_Mode_Control_CSA_w50kcnrstiffns_Test_yrmserr_v_ygain_fig_%s.fig', datestr(now,'mm-dd-yyyy_HH-MM'));
savefig(Filename_yrmserr_v_ygain_fig);

figure % new figure
hold on
ax1 = subplot(4,1,1); % top subplot
hold on
ax2 = subplot(4,1,2); % bottom subplot
hold on
ax3 = subplot(4,1,3); % bottom subplot
hold on
ax4 = subplot(4,1,4); % bottom subplot
hold on
if gdp > nsp
    gdp = nsp;
end

for m = 1:gdp
    hold on
    plot(ax1,VMC(:,10),VMC_Vx (:,m))
    plot(ax2,VMC(:,10),VMC_Vy (:,m))
    plot(ax3,VMC(:,10),VMC_r (:,m))
    plot(ax4,VMC(:,10),VMC_YE (:,m))
end

Filename_fig = sprintf('Sliding_Mode_Control_CSA_w50kcnrstiffns_Test_fig_%s.fig', datestr(now,'mm-dd-yyyy_HH-MM'));
savefig(Filename_fig);