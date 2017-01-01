clear
port = 'COM9';
BaudRate = 115200;
NOC = 8; %number of channels
BPC = 2; %bytes per channel
voltage_max = 5;
N = 14; % TO BE CORRECTED
%sample_rate = 1000;
refresh_rate = 50;
%divider = sample_rate/refresh_rate;
%divider = 10;
data = zeros(NOC, refresh_rate);
x = -1:refresh_rate-1; % x(-1) is a dummy point equals NaN
h = gobjects(8,1);


f = figure('CloseRequestFcn',@cleanUp);
log = fopen('data_log.txt','w+');

for j = 1:NOC
%     subplot(2,4,j)
%     h(j) = plot(x,data(1,:));
%     title(['Channel ', int2str(j)]);
%     axis([0 refresh_rate-1 -1*voltage_max voltage_max])
    ax = subplot(2,4,j);
    h(j) = animatedline(ax,'MaximumNumPoints',refresh_rate + 1);
    title(['Channel ', int2str(j)]);
    axis([0 refresh_rate-1 -1*voltage_max voltage_max])
end

ardu=serial(port, 'BaudRate', BaudRate); % automatic COM detection to be added

try
    i = 1;
    k = 0;
    fopen(ardu);
    flushinput(ardu);
    fprintf(ardu, 'start');
    ardu_answer = fscanf(ardu,'%s');
    assert(strcmp(ardu_answer,'start'));
    %tic
    while true
        while (ardu.BytesAvailable < (NOC * BPC))
        end
        %ardu.BytesAvailable
        received_data = fread(ardu,NOC,'int16') * (voltage_max/2^(N-1));
        fprintf(log,'%f\t',received_data(:));
        fprintf(log,'\n');
        i = i + 1;
        %data(:,i) = received_data;
        for j = 1:NOC
            addpoints(h(j),x(i),received_data(j));
        end
        drawnow limitrate
        if i == (refresh_rate + 1)
            i = 1;
            for j = 1:NOC
                addpoints(h(j),x(1),NaN);
            end
        end
        k = k + 1;
        if k == 200*refresh_rate
            break
        end
    end
    %toc
    
catch ME
    ports = instrfindall;
    fclose(ports);
    delete(ports);
    clear ports
    fclose(log);
    rethrow(ME)
end

function cleanUp(src,callbackdata)
    delete(src);
    ports = instrfindall;
    fclose(ports);
    delete(ports);
    fclose(log);
    clear ports
end
