classdef ZwickTest
    %ZwickTest allows analysis of raw data output from Zwick Instrument.
    %   Data Updated:       Date Created: 1/10/20 
    %   Bibek Karki
    %   The instrument is retained at Magnetic Materials Laboratory
    %   Boise State University
    %   
    
    properties
        filename
        T % Table of output from Zwick testing
        lwh % array of length,width,height of the sample [mm]
    end
    
    properties(Access = protected)
        force % [N]
        elong % [m]
    end
    
    properties(Dependent)
        strain
        stress % Stress in MPa
    end
    
    properties (Constant, Access = protected)
        deflwh = [1 1 1.001];
    end
    
    methods
        
        function obj = ZwickTest(fname, lwh)
            if nargin == 1
                obj.lwh = obj.deflwh;
            else
               obj.lwh = lwh; 
            end
            %ZwickTest Construct an instance of this class
            obj.filename = fname;
            obj.T = readtable(fname); %name of the file
            
        end
        
        function outputArg = get.elong(obj)
            %Captures the elngation data
            outputArg = obj.T{:,3};
        end
        
        
        function outputArg = get.force(obj)
            %Captures the force data
            outputArg = obj.T{:,4};
        end
        
        function plotdispForce(obj)
            scatter(obj.force,obj.elong,20,'filled')
            xlabel('elongation (m)')
            ylabel('Force (N)')
            title(obj.filename)
            set(gca,'FontSize',20,'FontName','Helvetica')
            set(gcf,'color','w')
            set(gca, 'XDir','reverse')
            box on
            grid on
        end
        
        function outputArg = get.strain(obj)
            L = max(obj.lwh);  % [mm]
            L = L ./ 1000; % [m]
            outputArg = (obj.elong - obj.elong(1)) ./ L;
        end
        
        function outputArg = get.stress(obj)
            A = obj.lwh;
            A = prod(A(A~=max(A)));
            outputArg = obj.force ./ A; 
        end
        
        function plotStressStrain(obj)
            scatter(obj.strain,obj.stress,20,'filled')
            xlabel('strain')
            ylabel('stress (MPa)')
            title(obj.filename)
            set(gca,'FontSize',20,'FontName','Helvetica')
            set(gcf,'color','w')
            set(gca, 'XDir','reverse')
            box on
            grid on
        end
    end
end

