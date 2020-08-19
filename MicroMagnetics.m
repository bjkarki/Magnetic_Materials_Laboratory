classdef MicroMagnetics
    %MMDomainMap allows visualization of micro-magnetics fortran output.
    %   Data Updated: 08/18/20      Date Created: 08/18/20 
    %   Bibek Karki
    %   Input Argument: A = MMDomainMap(filename)
    %   Output properties :filename
    %   Methods: tyx(), uvw(), domainMap(), vectorMap(),
    
    properties
        filename % Name of the mdata00*.txt file
    end
    
    methods
        
        %MMDomainMap Construct an instance of this class
        % Syntax: obj = MicroMagnetics(fname)
        function obj = MicroMagnetics(fname)
            % Store filename
            obj.filename = fname;
        end
        
        % Method to plot the magnetic field domain orientation
        % Syntax: obj.domainMap()
        function domainMap(obj)
            % import and set required variables
            [u,v,~] = obj.uvw();
            [~,y,x] = obj.tyx();
            % I believe this Magnetic Moment alignment
            theta = zeros(y,x);
            for i = 1 : y
                for j = 1 : x
                    theta(i,j) = atan2d(v(i,j),u(i,j));
                end
            end
            % Draw figure
            figure
            set(gcf,'color','w')
            imagesc(theta')
            caxis([-180 180])
            colormap(hsv)
            set(gca,'YDir','normal')
            daspect([1 1 1])
            h = colorbar;
            title(h, 'degree')
            set(h,'XTick',[-180, -90, 0, 90, 180])
            set(gca,'FontSize',18,'FontName','Helvetica')
            title('Magnetic Domain')
            
        end
        
        % Method to plot the magnetic field moments
        % Syntax: obj.vectorMap()
        function vectorMap(obj)
            % import and set required variables
            [u,v,~] = obj.uvw();
            % draw figure
            figure
            set(gcf,'color','w')
            quiver(u',v',0.5)
            axis tight
            daspect([1 1 1])
            set(gca,'FontSize',16,'FontName','Helvetica')
            title('Magnetic Moment vectors')
            
        end
        
        % Method to obtain heat plot
        % Syntax: obj.heatplot(fname, it)
        function heatplot(obj,fname,it)
            % import and set required variables
            a = textread(fname);
            [~,y,x] = obj.tyx();
            % number of data points per iteration
            n = x * y;
            % instances of heatplot during iterative cycle
            l = length(a)./n;
            % reshape to identify no. of times heat plot was obtained
            a = reshape(a,n,l);
            % preview only the heatplot of final iteration           
            a = a (:,it);
            % reshape to correct format: y by x
            a = reshape(a,y,x);
            % correct unit: convert from J to kJ/m^3
            a = a ./ (4.05E-21);% conversion from Medha
            % Draw figure
            figure
            set(gcf,'color','w')
            imagesc(a')
            h = colorbar;
            title(h, 'kJ/m^3')
            set(gca,'YDir','normal')
            set(gca,'FontSize',16,'FontName','Helvetica')
            daspect([1 1 1])
            title(fname)
            
        end
        
        % Method to obtain energy minimization plot;
        % Syntax: obj.energyplot()
        function energyplot(~)
            % import and set required variables
            a = textread('history');
            a = a ./ (4.05E-21); % conversion from Medha
            % Draw figure
            figure
            set(gcf,'color','w')
            plot(a)
            xlabel('# of iterations')
            ylabel('Energy (kJ/m^3)')
            title('Energy vs. # of iterations')
            set(gca,'FontSize',16,'FontName','Helvetica')
            
        end
        
    end
    
    methods (Hidden)
        
        % Method to obtain t, y and x from the data
        % Syntax: [t,y,x] = obj.tyx()
        function [t,y,x] = tyx(obj)
            % name of the file
            file = obj.filename;
            % open file in read mode
            fid=fopen(file,'r'); 
            % Store the necessary variables
            t=fscanf(fid,'%f',[1,1]); % time
            y=fscanf(fid,'%d',[1,1]); % number of x-slices
            x=fscanf(fid,'%d',[1,1]); % number of y-slices
            % close file
            fclose(fid);
        end
        
        % Method to import magnetic moment vectors
        % Syntax: [u,v,w] = obj.uvw()
        function [u,v,w] = uvw(obj)
            % name of the file
            file = obj.filename;
            % import and set required variables
            [~,y,x] = obj.tyx();
            n = y * x;
            % open, read and close the file
            fid=fopen(file,'r');
            % ignore first 3 lines
            fscanf(fid,'%f',[1,1]); 
            fscanf(fid,'%d',[1,1]);
            fscanf(fid,'%d',[1,1]);
            % magnetic moment projection along u, v and w direction
            data=fscanf(fid,'%f',[3,n]);
            fclose(fid);
            % get magnetic moment along each basis in y*x map
            u=reshape(data(1,:),y,x); % first column of output file stored as u: ny by nx
            v=reshape(data(2,:),y,x); % second column of output file stored as v: ny by nx
            w=reshape(data(3,:),y,x); % third column of output file stored as w: ny by nx
            
        end
        
    end
    
end