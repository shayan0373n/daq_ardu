clear
port = 'COM6';
BaudRate = 115200;
NOC = 8; %number of channels
BPC = 2; %bytes per channel
voltage_max = 5;
N = 16; % TO BE CORRECTED
sample_rate = 1000;
refresh_rate = 50;
divider = sample_rate/refresh_rate;
data = zeros(NOC, refresh_rate);
x = 0:refresh_rate-1;
h = gobjects(8,1);


f = figure('CloseRequestFcn',@cleanUp);
log = fopen('data_log.txt','w+');

for j = 1:NOC
    subplot(2,4,j)
    h(j) = plot(x,data(1,:));
    title(['Channel ', int2str(j)]);
    axis([0 refresh_rate-1 -1*voltage_max voltage_max])
end

ardu=serial(port, 'BaudRate', BaudRate); % automatic COM detection to be added
try
    fopen(ardu);
    i = 0;
    k = 0;
    while true
        i = i + 1;
        while (ardu.BytesAvailable < (NOC * BPC))
        end
        received_data = fread(ardu,NOC,'int16') * (voltage_max/2^(N-1));
        %fprintf(log,'%f\t',received_data);
        %fprintf(log,'\n');
        if mod(i,divider) == 1
            k = k + 1;
            data(:,k) = received_data;
            for j = 1:NOC
                %h(j).YData = data(j,:);
                set(h(j),'YData', data(j,:))
            end
            drawnow limitrate
            k = mod(k, refresh_rate);
        end
        %i = mod(i, sample_rate);
    end
    
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
