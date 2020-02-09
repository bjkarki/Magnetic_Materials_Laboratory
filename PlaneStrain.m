classdef PlaneStrain
    
    properties (Access = public)
        e % eccentricity of the deformed ellipse
    end
    
    
    %properties (Constant)
     %   r = 5; % a random choice for the radius of the circle
    %end
    
    properties (Access = protected)
        r = 5;
        vertices
        tintersect
        xlimit
        ylimit
        Rmatrix
    end
    
    properties(Dependent)
        twophi % angle between k1 and k2, also k1' and k2'
        alpha % angle betwee k1' and k1, or k2' and k2
    end
    methods
        function obj = PlaneStrain(e)
            obj.e = e; % eccentricity of the ellipse
        end
        
        function output = get.vertices(obj)
            % obtains a and b from the eccentricity of the ellipse
            syms a b 
            eqn1 = a*b==obj.r^2;
            eqn2 = obj.e== sqrt(a^2 - b^2)./a;
            soln = solve(eqn1,eqn2,a,b);
            output = [double(soln.a(1)), double(soln.b(1))];
        end
        
        function soln = get.tintersect(obj)
            % t is the parametrization of circle and ellpse
            % identifies t= t0 where the circle and ellipse
            % coincide
            syms t
            xcircle = obj.r*cos(t);
            ycircle = obj.r*sin(t);
            
            xellipse = obj.vertices(1)*cos(t);
            yellipse = obj.vertices(2)*sin(t);
            
            eqn = xcircle^2 + ycircle^2 == xellipse^2 + yellipse^2;
            soln = double(solve(eqn,t));
        end
        
        function output = get.twophi(obj)
            % obtains angle between conjugate undistorted planes
            % ie. angle between k1 and k2 (also k1' and k2')
            t = obj.tintersect();
            m1 = sin(t(1)) ./ cos(t(1));
            m2 = sin(t(2)) ./ cos(t(2));
            output = abs(atand((m2-m1)./(1+m1*m2)));
        end
        
        function output = get.alpha(obj)
            % obtains angle between k1 and k1' (type II twinning)
            % or the angle between k2 and k2' (type I twinning)
            output = 90 - obj.twophi; 
        end 
        
        function output = get.xlimit(obj)
            % obtains x-axis limit for the figure
            output = floor(obj.vertices(1)+1);
        end
        
        function output = get.ylimit(obj)
            % obtains y-axis limit for the figure
            output = floor(obj.r + 1);
        end
        
        function soln = get.Rmatrix(obj)
            % obtains the Rotational matrix to coincide
            % k1 and k1' (type I twinning)
            % k2 and k2' (type II twinning)
            theta = obj.alpha;
            soln  = [ ...
                cosd(theta), sind(theta);...
                -sind(theta), cosd(theta)];
        end
        
        function plotCircle(obj)
            t = linspace(0,2*pi,200);
            x = obj.r*cos(t);
            y = obj.r*sin(t);
            plot(x,y,'b','LineWidth',2)
            axis equal
            xlim([-obj.xlimit obj.xlimit])
            ylim([-obj.ylimit obj.ylimit])
            set(gca,'FontName','Times New Roman','FontSize',18)
            ax = gca;
            rtick = floor(-obj.r):2:ceil(obj.r);
            ax.XTick = rtick;
            ax.YTick = rtick;
            ax.XTickLabel =[];
            ax.YTickLabel = [];
            grid on; box on;
            clear t x y ax
            
        end
        
        function plotEllipse(obj)
            t = linspace(0,2*pi,200);
            x = obj.vertices(1).*cos(t);
            y = obj.vertices(2).*sin(t);
            plot(x,y,'r','LineWidth',2)
            axis equal
            xlim([-obj.xlimit obj.xlimit])
            ylim([-obj.ylimit obj.ylimit])
            set(gca,'FontName','Times New Roman','FontSize',18)
            ax = gca;
            ax.XTickLabel =[];
            ax.YTickLabel = [];
            grid on; box on;
            clear t x y ax
        end    
        
        function plotK(obj)
            t = obj.tintersect;
            
            m1 = sin(t(1))./cos(t(1));
            m2 = sin(t(2))./cos(t(2));
            
            syms x
            fplot(x,m1*x,[-obj.ylimit obj.ylimit],'b:','LineWidth',2), hold on
            fplot(x,m2*x,[-obj.ylimit obj.ylimit],'b:','LineWidth',2)
            xlim([-obj.xlimit obj.xlimit])
            ylim([-obj.ylimit obj.ylimit])
        end
        
        function plotKprime(obj)
            t = obj.tintersect;
            a = obj.vertices(1);
            b = obj.vertices(2);
            
            m1 = (b.*sin(t(1))) /(a.*cos(t(1)));
            m2 = (b.*sin(t(2))) /(a.*cos(t(2)));
            
            syms x
            fplot(x,m1*x,[-obj.ylimit obj.ylimit],'r:','LineWidth',2), hold on
            fplot(x,m2*x,[-obj.ylimit obj.ylimit],'r:','LineWidth',2)
            xlim([-obj.xlimit obj.xlimit])
            ylim([-obj.ylimit obj.ylimit])
        end
        
        function plotREllipse(obj)
            t = linspace(0,2*pi,200);
            a = obj.vertices(1);
            b = obj.vertices(2);
            
            x = a.*cos(t);
            y = b.*sin(t);
            rCoords = obj.Rmatrix*[x ; y];   
            xr = rCoords(1,:)';      
            yr = rCoords(2,:)';
            plot(xr,yr,'k','LineWidth',2)
        end
        
        function plotRKprime(obj)
            t = obj.tintersect;
            a = obj.vertices(1);
            b = obj.vertices(2);
            x = a.*cos(t);
            y = b.*sin(t);
            rCoords = obj.Rmatrix*[x' ; y'];
            xr = rCoords(1,:)';      
            yr = rCoords(2,:)';
            
            m1 = yr(1)./xr(1);
            m2 = yr(2)./xr(2);
            
            syms x
            fplot(x,m1*x,[-obj.ylimit obj.ylimit],'k:','LineWidth',2), hold on
            fplot(x,m2*x,[-obj.ylimit obj.ylimit],'k:','LineWidth',2)
            xlim([-obj.xlimit obj.xlimit])
            ylim([-obj.ylimit obj.ylimit])
            
        end
        
        function plotAll(obj)
            figure, hold on
            obj.plotCircle();
            obj.plotK();
            pause
            obj.plotEllipse();
            obj.plotKprime();
            pause
            obj.plotREllipse();
            obj.plotRKprime();
            hold off
        end
    end
end