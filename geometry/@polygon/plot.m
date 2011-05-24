function varargout = plot(p,varargin)
% function for plotting polygons, mainly use to visualize grains
%
%% Input
%  p - @polygon
%
%% Output
%  handles - handles to the plotted patches
%
%% Options
%  fill   - fill color
%  region - clipping region
%
%% See also
% grain/plot


%preparing canvas
set(gcf,'renderer','zbuffer');
if ~check_option(varargin,'nofix'), fixMTEXplot('noresize');end

%%
[ig ig lx ly] = fixMTEXscreencoordinates(1,1,varargin{:});

% set direction of x and y axis
xlabel(lx);ylabel(ly);

p = polygon(p);

%% plot filled polygons
if check_option(varargin,'fill') || check_option(varargin,'FaceColor')
  
  % get filling
  c = get_option(varargin,'fill');
  if islogical(c), c = double(c); end  
  
  % add holes as polygons
	if ~check_option(varargin,'noHoles') && ~check_option(varargin,'FaceColor')
    
    % take all polygons that have a hole
    hole = hashole(p);
    
    % make list of holes
    tmp_ph = ([p(hole).Holes]);
   
    % update number of holes
    nl = numel(p); nlh = numel(tmp_ph);    
    
    % add add the holes to the list of polygons
    p = [tmp_ph p ];

    % set fill to 1 for the holes ???
    c(nlh+1:nl+nlh,:) = c;
    c(1:nlh,:) = 1; 
  end
  
  pl = cellfun('prodofsize',{p.Vertices});
  A = area(p);
  
  ind = splitdata(pl,fix(log(length(pl))/2),'ascend');
  
  for k=length(ind):-1:1  
    ndx = ind{k};
    [ignore zorder] = sort(A(ndx),'descend');    
    zorder = ndx(zorder);
    
    [faces vertices] = get_faces(p(zorder));
    [vertices(:,1), vertices(:,2)] = fixMTEXscreencoordinates(vertices(:,1),vertices(:,2),varargin{:});
  
    % additional arguments if color is given by indexing
    if ~isempty(c)
      CData = {'FaceVertexCData',c(zorder,:),'FaceColor','flat'};
    else
      CData = {};
    end    
    
    % plot the patches
    h(k) = patch('Vertices',vertices,'Faces',faces,CData{:});
    optiondraw(h(k),varargin{:});
    
  end
  
  % remove from legend for splitted patches
   setLegend(h(2:end),'off');
  
elseif check_option(varargin,'pair')
%
	pair = get_option(varargin,'pair');
 	
  if ~isempty(pair)
    npair = size(pair,1);
    
    boundary = cell(1,npair);

    VertexIds = get(p,'VertexIds');
    pVertices = get(p,'Vertices','cell');

    for k=find(hashole(p))
      pHoles = get(p(k),'Holes');
      hVertexIds = get(pHoles,'vertexids');
      VertexIds{k} = [VertexIds{k} hVertexIds{:}];
      pVertices{k} = vertcat(pVertices{k},get(pHoles,'Vertices'));
    end
    
    VertexIds = VertexIds(pair(:,1:2));
    pVertices = pVertices( pair(:,2) );

    for k=1:npair

      b1 = VertexIds{k,1};
      b2 = VertexIds{k,2};
      
      %	r = find(ismember(b2,b1));       
      
      [b1 n1] = sort(b1);
      [b2 n2] = sort(b2);      
      rr = ismembc(b2,b1);      
      r = sort(n2(rr));
      
      pos = find(diff(r)>1);
      npos = numel(pos);
      
      Vertices =  pVertices{ k };   
      border = [];
      if npos > 0
        pos = [0 pos numel(r)];
        for j=1:npos
          border = [border; Vertices(r(pos(j)+1:pos(j+1)),:)];
          border(end+1,:) = NaN;
        end
      else
        border = Vertices(r,:);
        border(end+1,:) = NaN;
      end
    
      boundary{k} = border;

    end

    Vertices = vertcat(boundary{:});
    

    if ~isempty(Vertices)

      [Vertices(:,1), Vertices(:,2)] = fixMTEXscreencoordinates(Vertices(:,1), Vertices(:,2), varargin{:});

      if size(pair,2) == 2 % colorize monotone

        h = line(Vertices(:,1),Vertices(:,2)); 

      else % colorize colormap

        d = pair(:,3:end);

        cs = cellfun('prodofsize',boundary)/2;
        csz = [0 cumsum(cs)];

        c = ones(size(Vertices,1),size(d,2));
        for k=1:size(pair,1)
          
          c( csz(k)+1:csz(k+1) , : ) = d( k*ones( cs( k ) ,1) ,:);      

        end

        h = patch('Faces',1:size(Vertices,1),'Vertices',Vertices,'EdgeColor','flat',...
        'FaceVertexCData',c);

      end
    end
        
  end
else
  
  if ~check_option(varargin,'noHoles')
    p = [p [p(hashole(p)).Holes]];
  end
% varargin
  Vertices = get(p,'Vertices','plot');
 
  if ~isempty(Vertices)
    [X,Y] = fixMTEXscreencoordinates(Vertices(:,1),Vertices(:,2),varargin{:});
    h = line(X(:),Y(:));
  end
  % axis equal
end

if ~check_option(varargin,'nofix')
  fixMTEXplot
  set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});
end


if exist('h','var'), 
  optiondraw(h,varargin{:});
else
  h = [];  
end

if nargout > 0, varargout{1} = h; varargout{2:nargout} = []; end



function [faces vertices] = get_faces(p)

vertices = vertcat(p.Vertices);
cl = cellfun('length',{p.Vertices});
rl = max(cl);
crl = [0 cumsum(cl)];
faces = NaN(numel(p),rl);
for k = 1:numel(p)
  faces(k,1:cl(k)) = (crl(k)+1):crl(k+1);
end



