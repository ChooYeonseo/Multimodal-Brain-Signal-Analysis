function save_as_TIF(str, ch, idx, fignum, dir_data, t_start, t_end)
% Set default values if arguments are missing
if nargin < 7  % If t_end is not provided, set default value
    t_end = 20;
end
if nargin < 6  % If t_start is not provided, set default value
    t_start = 15;
end

% Display values for debugging
fprintf('t_start = %d, t_end = %d\n', t_start, t_end);
n = length(ch);
clear data;
figure(fignum);
fign = fignum;
set(fign, 'Units', 'inches', 'PaperPositionMode', 'auto');
set(fign, 'Position', [1 1 15 10]);

t1 =15;%처음 시간 (0초 이상의 시간을 기입해주세요. 0초에 대한 데이터는 없기 때문에 0으로 기입시 에러가 발생합니다.)
t2 =20;%끝나는 시간
prefname = '';
postfname = ''; %저장되는 파일 이름

clist = [jet(length(ch))];

for i = 1:length(ch),
    fname = sprintf('%s%i', prefname, ch{i});
    load(fullfile(dir_data, [str{i} fname '.mat']));
    data.x = data.x - data.x(1);

    if i == 1,
        tinx_beg = max(find(data.x < t1));
        tinx_end = max(find(data.x < t2));

        iinx = [tinx_beg:tinx_end];
        xinterp = data.x(iinx);
    end

    dataD.x = data.x(iinx); dataD.x = dataD.x -dataD.x(1);

    dataD.y = data.y(iinx);
    subplot(n,1,i);
    plot(dataD.x, dataD.y, 'Color', 'k'); 
    hold on;
    axis([dataD.x(1) dataD.x(end) -1000 1000]);
    set(gca, 'visible', 'off');
    clear data; 
    data = dataD;
    clear dataD data
    hold off;
end

fn = fullfile(dir_data, [num2str(idx) postfname '.tif']);
saveas(gcf, fn);
end