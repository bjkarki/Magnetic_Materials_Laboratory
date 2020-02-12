classdef XRDBruker
    %XRDBruker allows analysis of raw data output from XRD Bruker Instrument.
    %   Data Updated: 02/12/20      Date Created: 1/13/20 
    %   Bibek Karki
    %   
    
    properties
        filename
        data % Table of output from XRD tests
        names % chi or two theta    
    end
    
    methods
        
        function obj = XRDBruker(fname)
            %XRDBruker Construct an instance of this class
            % check if filname is inserted in correct format
            if ischar(fname) == 0
                error('Please input file name in character form and try again.'); 
            end 
            % store the name of the file
            obj.filename = fname;
            % Open the file & read first line
            fid = fopen(fname);
            % instance of output cell
            Data = {};
            % loop to read until the end of line
            while ~feof(fid)
                % read each line
                read_line = fgetl(fid);
                % Does the line contain 'Data for range'
                if contains(read_line, 'Data for range ')
                    a = strfind(read_line,'Data for range ');
                    b = length('Data for range ');
                    n = str2double(read_line(a+b:end));
                    Data{n} = [];
                    clear a b
                end
                % convert each lines to numbers. Returns empty if character or string in the line
                if contains(read_line,'; KHI')
                    Names(n) = "chi vs intensity";
                elseif contains (read_line,'; 2THETA')
                    Names(n) = "2theta vs intensity";
                end
                    
                numbers = str2num(read_line);
                % If numbers variable is not empty gather data.
                if ~isempty(numbers)
                    Data{n} = [Data{n}; [numbers(1), numbers(2)]];
                end
            end
            obj.data = Data;
            obj.names = Names;
        end
        
        function plotAll(obj)
            %%plots overlaid 2theta vs intensity plot for all data
            ind = obj.names == "chi vs intensity";
            
            if ~isempty(ind)
                figure, hold on
                Data = obj.data(ind);
                for i = 1 : length(Data)
                    X = Data{i};
                    plot(X(:,1),X(:,2),'LineWidth',1)
                end
                xlabel('\chi'), ylabel('counts'), title(obj.filename(1:end-4))
                set(gca,'FontSize',20,'FontName','Helvetica')
                set(gcf,'color','w')
                grid on, box on, axis tight
                hold off
            end
            
            figure, hold on
            Data = obj.data(~ind);
            for i = 1 : length(Data)
                X = Data{i};
                plot(X(:,1),X(:,2),'LineWidth',1)
            end
            xlabel('2\theta'), ylabel('counts'), title(obj.filename(1:end-4))
            set(gca,'FontSize',20,'FontName','Helvetica')
            set(gcf,'color','w')
            grid on, box on, axis tight
            hold off
        end
        
        function plotTest(obj, n)
            %%plots overlaid 2theta vs intensity plot for given test no.
            X = obj.data{n};
            plot(X(:,1),X(:,2),'LineWidth',1)
            if obj.names(n) == "chi vs intensity"
                xlabel('\chi')
            else
                xlabel('2\theta')
            end
            ylabel('counts'), title(strcat(obj.filename(1:end-4),' test-',num2str(n)))
            set(gca,'FontSize',20,'FontName','Helvetica')
            set(gcf,'color','w')
            grid on, box on
        end
        
        function outputArg = c_over_a_NM(obj,cutoff)
            % select only twotheta vs intensity dataset
            ind = obj.names == "chi vs intensity";
            Data = obj.data(~ind);
            
            for i = 1 : length(Data)
                test = Data{i}; % obtain matrix of a test
                twotheta = test(:,1); % two theta
                counts = test(:,2); % intensity
                
                % indices of data below cutoff twotheta
                j = twotheta <= cutoff;
                
                % a = index of maximum instensity for twotheta <= cutoff
                [~,a] = max(counts(j));
                
                % b+c = index of maximum intensity for twotheta > cutoff
                b = length(counts(j));
                [~,c] = max(counts(~j));
                
                % c/a = sine of bigger angle over sine of smaller angle 
                ca(i) = sind(twotheta(b+c)/2)/sind(twotheta(a)/2);
                
            end
            % plot output
            outputArg = ca;
        end
        
        function output = offaxis(obj)
            % check if the input dataset is correct
             % select only twotheta vs intensity dataset
            ind = obj.names == "chi vs intensity";
            if isempty(ind)
                error ('The function does not containt chi vs intensity data') 
            else
                Data = obj.data(ind);
            end
            
            for i = 1:length(Data)
                X = Data{i};
                chi = X(:,1); counts = X(:,2);
                % indices of data below cutoff twotheta
                j = chi <= -90;
                [~,a] = max(counts(j));
                b = length(counts(j));
                [~,c] = max(counts(~j));

                axistilt(i) = abs(chi(a)-chi(b+c))/4;
            end
            output = axistilt;
        end
    end
end

