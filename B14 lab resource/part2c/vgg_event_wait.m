function [x,y,button,type] = vgg_event_wait(callback_arg)

% VGG_EVENT_WAIT Wait for a mouse or key event, including motion.
%
% button: 0 motion
%         1 left
%         2 middle
%         3 right
%
%
% type:  0 motion
%       +1 button down
%       -1 button up
%        2 key pressed (button is ASCII code)
%

% $Id: vgg_event_wait.m,v 1.4 2003/11/18 08:21:50 vgg Exp $
% Author: Andrew Fitzgibbon <awf@robots.ox.ac.uk>
% Date: 09 Aug 97

global VGG_EVENT_WAIT_E VGG_EVENT_WAIT_DOWN VGG_EVENT_WAIT_HANDLE

if isempty(VGG_EVENT_WAIT_DOWN)
  VGG_EVENT_WAIT_DOWN = 0;
end

if nargin == 1
  if strcmp(callback_arg, 'clear')
    VGG_EVENT_WAIT_DOWN = 0;
    VGG_EVENT_WAIT_E = [0 0 0 0];
    return
  end
end
  

if nargin == 0
  interruptible = get(gcf, 'interruptible');
  set(gcf, 'interruptible', 'off');
  
  % User entry point
  motion_fcn = get(gcf, 'WindowButtonMotionFcn'); set(gcf, 'WindowButtonMotionFcn', 'vgg_event_wait(''motion'')');
  down_fcn = get(gcf, 'WindowButtonDownFcn'); set(gcf, 'WindowButtonDownFcn', 'vgg_event_wait(''down'')');
  up_fcn = get(gcf, 'WindowButtonUpFcn'); set(gcf, 'WindowButtonUpFcn', 'vgg_event_wait(''up'')');
  keypress_fcn = get(gcf, 'KeyPressFcn'); set(gcf, 'KeyPressFcn', 'vgg_event_wait(''key'')');

  VGG_EVENT_WAIT_HANDLE = line(nan,nan, 'visible', 'off', 'userdata', 0);
  VGG_EVENT_WAIT_E = [0 0 0 0];
  error_occurred = 0;
  lasterr('')
  while ~any(VGG_EVENT_WAIT_E)
    try
      waitfor(VGG_EVENT_WAIT_HANDLE, 'userdata');
    catch
      error_occurred = 1;
      break
    end
  end
  x = VGG_EVENT_WAIT_E(1);
  y = VGG_EVENT_WAIT_E(2);
  button = VGG_EVENT_WAIT_E(3);
  type = VGG_EVENT_WAIT_E(4);
  
  % Clear motion function
  set(gcf, 'WindowButtonMotionFcn', '');
  set(gcf, 'WindowButtonDownFcn', '');
  set(gcf, 'WindowButtonUpFcn', '');
  set(gcf, 'KeyPressFcn', '');
  set(gcf, 'interruptible', interruptible);
  
  delete(VGG_EVENT_WAIT_HANDLE);
  clear global VGG_EVENT_WAIT_E VGG_EVENT_WAIT_HANDLE
  if error_occurred
    error(['vgg_event_wait: PASSTHRU: [' lasterr ']']);
  end
  return
end


%%%%% Callback entry point
% Get XY pos
p = get(gca, 'currentpoint');
p = [p(1,1) p(1,2)];

% Find which mouse button is pressed
button = get(gcf, 'SelectionType');
if strcmp(button,'open')
  button = 4;
elseif strcmp(button,'normal')
  button = 1;
elseif strcmp(button,'extend')
  button = 2;
elseif strcmp(button,'alt')
  button = 3;
else
  error('Invalid mouse selection.')
end

VERBOSE = 0;

% fill waiting VGG_EVENT_WAIT_E struct
if strcmp(callback_arg, 'motion')
  if VERBOSE, fprintf('.'); end
  VGG_EVENT_WAIT_E = [p button*VGG_EVENT_WAIT_DOWN 0];
elseif strcmp(callback_arg, 'down')
  if VERBOSE, fprintf('d'); end
  VGG_EVENT_WAIT_E = [p button 1];
  VGG_EVENT_WAIT_DOWN = 1;
elseif strcmp(callback_arg, 'up')
  if VERBOSE, fprintf('u'); end
  VGG_EVENT_WAIT_E = [p button -1];
  VGG_EVENT_WAIT_DOWN = 0;
elseif strcmp(callback_arg, 'key')
  if VERBOSE, fprintf('k'); end
  key = get(gcf,'CurrentCharacter');
  if any(abs(key))
    VGG_EVENT_WAIT_E = [p abs(key) 2];
  end
end
set(VGG_EVENT_WAIT_HANDLE, 'userdata', 1);
