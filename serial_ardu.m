clear
NOC = 8; %number of channels
BPC = 2; %bytes per channel
log = fopen('data_log.txt','w+');
voltage_max = 5;
N = 16;
sample_rate = 50;
data = zeros(NOC, sample_rate);
x = 0:sample_rate-1;
h = gobjects(8,1);
figure
for j = 1:NOC
    ax = subplot(2,4,j);
    h(j) = animatedline(ax,'MaximumNumPoints',sample_rate);
    title(['Channel ', int2str(j)]);
    axis([0 sample_rate-1 0 1])
end

tic
i = 0;
k = 0;
while true
    i = 1 + i;
    received_data = rand(NOC, 1);
    fprintf(log,'%d\t',received_data);
    fprintf(log,'\n');
    data(:,i) = received_data;
%     if i == 25
%         set(h,'LineStyle','none')
%     end
%     if i == 2
%         set(h,'LineStyle', '-')
%     end
    if i==sample_rate
        for j = 1:NOC
            addpoints(h(j),x(:),data(j,:));
        end
        drawnow
        i=0;
    end
    %i = mod(i, sample_rate);
    k = k+1;
    if k == 100*sample_rate
        break
    end
end
toc
fclose(log);
