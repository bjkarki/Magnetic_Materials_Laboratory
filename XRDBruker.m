classdef XRDBruker
    %XRDBruker allows analysis of raw data output from XRD Bruker Instrument.
    %   Data Updated:       Date Created: 1/13/20 
    %   Bibek Karki
    %   
    
    properties
        filename
        data % Table of output from XRD tests   
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
                numbers = str2num(read_line);
                % If numbers variable is not empty gather data.
                if ~isempty(numbers)
                    Data{n} = [Data{n}; [numbers(1), numbers(2)]];
                end
            end
            obj.data = Data;
        end
        
        function plotAll(obj)
            %%plots overlaid 2theta vs intensity plot for all data
            figure, hold on
            for i = 1 : length(obj.data)
                X = obj.data{i};
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
            xlabel('2\theta'), ylabel('counts'), title(strcat(obj.filename,' test-',num2str(n)))
            set(gca,'FontSize',20,'FontName','Helvetica')
            set(gcf,'color','w')
            grid on, box on
        end
        
        function outputArg = cbyaRatio(obj,cutoff)
            % loop to calculate c by a ratio for each test
            for i = 1 : length(obj.data)
                test = obj.data{i}; % obtain matrix of a test
                twotheta = test(:,1); % two theta
                counts = test(:,2); % intensity
                % indices of data below cutoff twotheta
                j = twotheta <= cutoff;
                % dividing the table into two parts: below and above cutoff
                twotheta1 = twotheta(j); twotheta2 = twotheta(~j);
                counts1 = counts(j); counts2 = counts(~j);
                
                % index of the maximum peak and the twotheta at which it
                % occurs
                [~,si] = max(counts1); s = twotheta1(si);
                [~,li] = max(counts2); l = twotheta2(li);
                % calculated c by a ratio for given instance
                ca(i) = sind(l/2)./sind(s/2);
            end
            % plot output
            outputArg = ca;
        end      
    end
end

