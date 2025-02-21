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
%prefname = '15_fCSC';
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


    %       for q=1:tinx_end-tinx_beg,
    %               if dataD.y(q) < -250 &&  q > 500,
    %                 for t=q-1200:q+1200, % 60ms, 1sec=32000
    %                  dataD.y(t) = 0;
    %                 end
    %              end
    %       end
    %
    %      for q=1:tinx_end-tinx_beg,
    %               if dataD.y(q) > 250 &&  q > 500,
    %                 for t=q-1200:q+1200, % 60ms, 1sec=32000
    %                  dataD.y(t) = 0;
    %                 end
    %              end
    %       end

    subplot(n,1,i);
    plot(dataD.x, dataD.y, 'Color', 'k'); hold on;
    %  plot(dataD.x, dataD.y*1e6, 'Color', 'k'); hold on;
    %    l = legend(sprintf('No. %i', ch{i})); set(l, 'Box', 'Off');
    %set(gca, 'YTickLabel',{'-300','0', '300'},'YTick',[-300 0 300]);
    axis([dataD.x(1) dataD.x(end) -5000 5000]);
    set(gca, 'visible', 'off');


    %set(gca, 'FontSize', 9, 'FontW5eight', 'Bold', 'Position' ,[0.15 0.15 0.73 0.35]);
    %    text
    %    if i == floor(length(ch)/2),
    %        ylabel('V (\muV)', 'FontSize', 10, 'FontWeight', 'bold');
    %    end

    % text(15, 1-i*0.1+200, sprintf('Ch.%i', ch{i}), 'FontSize', 9, 'FontWeight', 'Bold');
    % save(['D:\Experiment\in-vitro\201807\2nd week\2\DIV6\1\' num2str(idx) postfname '.mat'], 'data');
    clear data; data = dataD;
    %    save([save_dir fname postfname '.mat'], 'data');

    %%
    clear dataD data
end

% xlabel('Time (s)', 'FontSize', 10, 'Fontweight', 'bold');
%set(gca, 'FontSize', 9, 'FontWeight', 'Bold', 'Position', [0.15 0.1 0.73 0.075]);
fn = fullfile(dir_data, [num2str(idx) postfname '.tif']);

%fn = [save_dir fname postfname '_1''.tif'];=
saveas(gcf, fn);
%  close(gcf);
%print('-f1', '-dtiff', '-r600', fn)
%figure(1)

end