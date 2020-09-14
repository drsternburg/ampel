# TrafficLight_decide.py -
# MSK, 2018
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#
#

import pygame, os
from FeedbackBase.PygameFeedback import PygameFeedback
from __builtin__ import str
from collections import deque


class TrafficLight_decide(PygameFeedback):


    def init(self):

        PygameFeedback.init(self)
        
        ########################################################################
        
        self.FPS = 200
        self.screenPos = [1280, 0]
        self.screenSize = [1280, 1024]
        self.screen_center = [self.screenSize[0]/2,self.screenSize[1]/2]
        self.caption = "TrafficLight"
        
        self.trafficlight_size = (self.screenSize[1]/6, self.screenSize[1]/2)
        self.trafficlight_states = ('','green','red','yellow')
        
        self.background_color = [127, 127, 127]
        self.text_fontsize = 75
        self.text_color = [64,64,64]
        self.char_fontsize = 100
        self.char_color = [0,0,0]
        
        self.pause_text = 'Paused. Press pedal to continue...'
        self.paused = True
        self.on_trial = False
        
        ########################################################################
        
        self.delay_before_trialend = 1500
        self.duration_light_on = 500
        self.duration_cross = 2500
        self.min_waittime = 1500
        self.max_waittime = 10000
        
        self.marker_keyboard_press = 199
        self.marker_quit = 255
        self.marker_trial_start = 10
        self.marker_base_interruption = 20
        self.marker_trial_end = 30
                
        self.marker_identifier = {self.marker_base_interruption+1 : 'random red light',
                                  self.marker_base_interruption+2 : 'random green light',
                                  self.marker_base_interruption+3 : 'random yellow light',
                                  self.marker_base_interruption+4 : 'move red light',
                                  self.marker_base_interruption+5 : 'move green light',
                                  self.marker_base_interruption+6 : 'move yellow light',
                                  self.marker_base_interruption+7 : 'idle red light',
                                  self.marker_base_interruption+8 : 'idle green light',
                                  self.marker_base_interruption+9 : 'idle yellow light'}
        
        ########################################################################
        # MAIN PARAMETERS TO BE SET IN MATLAB
        
        self.mode = 1 # 1 - self-paced, 2 - traffic light (no BCI), 3 - traffic light (BCI)
        self.trial_assignment = [4,5,6,4,5,6] # 1 - random red, 2 - random green, 3 - random yellow, 4 - move red, 5 - move green, 6 - move yellow, 7 - idle red, 8 - idle green, 9 - idle yellow
        self.cue_waittime = [3000.0,3000.0,3000.0,3000.0,3000.0,3000.0]
        self.pause_every_x_events = 3
        self.end_after_x_events = 6
        self.end_pause_counter_type = 1 # 1 - pedal presses, 2 - move lights, 3 - idle lights, 4 - seconds, 5 - trials, 6 - random lights, 7 - BCI lights
        self.listen_to_keyboard = 1
        
        ########################################################################  


    def pre_mainloop(self):
        PygameFeedback.pre_mainloop(self)
        self.font_text = pygame.font.Font(None, self.text_fontsize)
        self.font_char = pygame.font.Font(None, self.char_fontsize)
        self.trial_counter = 0
        self.block_counter = 0
        self.random_counter = 0
        self.move_counter = 0
        self.idle_counter = 0
        self.pedalpress_counter = 0
        self.time_recording_start = pygame.time.get_ticks() 
        if self.mode==3:
            self.queue_trial = deque(self.trial_assignment)
        if self.mode==2:
            self.queue_trial = deque(self.trial_assignment)
            self.queue_waittime = deque(self.cue_waittime)
        if self.mode==1:
            self.this_interruption_color = 'green'
        self.reset_trial_states()
        self.load_images()
        self.on_pause()
        
        
    def reset_trial_states(self):
        self.time_trial_end = float('infinity')
        self.time_trial_start = float('infinity')
        self.light_until = float('infinity')
        self.light_on = False
        self.already_interrupted = False
        self.already_pressed = False
        

    def post_mainloop(self):
        PygameFeedback.post_mainloop(self)
    
   
    def on_pause(self):
        self.log('Paused. Waiting for participant to continue...')
        self.time_trial_start = float('infinity')
        self.paused = True
        self.on_trial = False
    
    
    def unpause(self):
        self.log('Starting block '+str(self.block_counter+1))
        now = pygame.time.get_ticks()
        self.paused = False
        self.time_trial_end = now
        self.trial_counter -= 1 # ugly hack


    def tick(self):
        now = pygame.time.get_ticks()
        if self.listen_to_keyboard:
            self.on_keyboard_event()
        if not self.paused:
            # it's time to end trial
            if now > self.time_trial_end:
                self.on_trial = False
                self.reset_trial_states()
                self.trial_counter += 1
                self.send_parallel(self.marker_trial_end)
                self.time_trial_start = now + self.duration_cross
                self.time_trial_end = float('infinity')
            # it's time to start the next trial
            if now > self.time_trial_start:
                # however, first check if it's time ...
                # ... to stop
                if self.count_events() >= self.end_after_x_events:
                    self.send_parallel(self.marker_quit)
                    self.on_stop()
                # ... or to pause
                elif self.count_events() - self.pause_every_x_events*self.block_counter >= self.pause_every_x_events:
                    self.block_counter += 1
                    self.on_pause()
                # otherwise, start new trial
                else:
                    self.on_trial = True
                    self.this_trial()
                    self.send_parallel(self.marker_trial_start)
                    self.time_trial_start = float('infinity')
            # it's time for random interruption
            if self.mode==2 and self.on_trial and not self.already_interrupted and now > self.this_start_time + self.this_cue_time:
                self.random_counter += 1
                self.do_interruption()
            # it's time to end a BCI trial (too long waiting time)
            if self.mode==1 and self.on_trial and not self.already_interrupted and now > self.this_start_time + self.max_waittime;
                # reassign random marker to light
                if self.this_interruption_color=='red':
                    self.this_interruption_marker = self.marker_base_interruption+1;
                elif self.this_interruption_color=='green':
                    self.this_interruption_marker = self.marker_base_interruption+2;
                elif self.this_interruption_color=='yellow':
                    self.this_interruption_marker = self.marker_base_interruption+3;
                self.random_counter += 1
                self.do_interruption()
            # update traffic light
            self.change_traffic_light()
        self.present_stimulus()
    
    
    def count_events(self):
        if self.end_pause_counter_type==1:
            nr_events = self.pedalpress_counter
        elif self.end_pause_counter_type==2:
            nr_events = self.move_counter
        elif self.end_pause_counter_type==3:
            nr_events = self.idle_counter
        elif self.end_pause_counter_type==4:
            now = pygame.time.get_ticks()
            nr_events = (now - self.time_recording_start)/1000
        elif self.end_pause_counter_type==5:
            nr_events = self.trial_counter
        elif self.end_pause_counter_type==6:
            nr_events = self.random_counter
        elif self.end_pause_counter_type==7:
            nr_events = self.move_counter+self.idle_counter
        return nr_events

    
    def change_traffic_light(self):
        now = pygame.time.get_ticks()
        if now > self.light_until:
            self.light_on = False
            self.light_until = float('infinity')
        identifier = str()
        if self.light_on:
            identifier = identifier + self.this_interruption_color
        self.this_trafficlight_index = self.trafficlight_states.index(identifier)          
                
                
    def on_control_event(self,data):
        now = pygame.time.get_ticks()
        if self.on_trial and self.mode==3 and not self.already_interrupted and now > self.this_start_time + self.min_waittime:
            if u'cl_output' in data:
                if data[u'cl_output']==-1 and self.this_trial_type>3:
                    self.idle_counter += 1
                    self.do_interruption() # IDLE interruption
                if data[u'cl_output']==1 and self.this_trial_type<=3:
                    self.move_counter += 1
                    self.do_interruption() # MOVE interruption
        if u'pedal' in data:
            if data[u'pedal']==1:
                self.verify_press()

    
    def on_keyboard_event(self):
        self.process_pygame_events()
        if self.keypressed:
            self.keypressed = False
            self.verify_press()


    def verify_press(self):
        now = pygame.time.get_ticks()
        if self.mode==1 and self.on_trial and not self.already_pressed:
            self.light_on = True
            self.light_until = now + self.duration_light_on
            self.time_trial_end = now + self.delay_before_trialend
            self.pedal_press()
        if self.mode>1 and self.on_trial and not self.already_pressed and self.already_interrupted:
            self.pedal_press()
        if self.paused:
            self.unpause()
        
        
    def this_trial(self):
        self.reset_trial_states()
        now = pygame.time.get_ticks()
        self.this_start_time = now
        if self.mode==1:
            self.log('Trial %d | Waiting for pedal press...' % (self.trial_counter+1))
        else:
            self.this_trial_type = int(self.queue_trial.pop())
            self.this_interruption_marker = self.marker_base_interruption + self.this_trial_type
            if (self.this_trial_type==1) or (self.this_trial_type==4):
                self.this_interruption_color = 'red'
            elif (self.this_trial_type==2) or (self.this_trial_type==5):
                self.this_interruption_color = 'green'
            else:
                self.this_interruption_color = 'yellow'
            if self.mode==2:
                self.this_cue_time = self.queue_waittime.pop()
                self.log('Trial %d | %s | Presenting cue in %02.1f sec...' % (self.trial_counter+1,self.this_interruption_color,self.this_cue_time/1000))
            elif self.mode==3:
                if (self.this_trial_type==1) or (self.this_trial_type==2) or (self.this_trial_type==3):
                    self.log('Trial %d | RP+ | %s | Listening to classifier...' % (self.trial_counter+1,self.this_interruption_color))
                else:
                    self.log('Trial %d | RP- | %s | Listening to classifier...' % (self.trial_counter+1,self.this_interruption_color))
    
    
    def do_interruption(self):
        self.send_parallel_log(self.this_interruption_marker)
        now = pygame.time.get_ticks()
        self.already_interrupted = True
        self.light_on = True
        self.light_until = now + self.duration_light_on
        self.time_trial_end = now + self.delay_before_trialend
        
    
    def pedal_press(self):
        self.already_pressed = True
        self.pedalpress_counter += 1
        self.log('Pedal press')


    def present_stimulus(self):
        self.screen.fill(self.background_color)
        if self.paused:
            self.render_text(self.pause_text)
        else:
            if self.on_trial:
                self.show_trafficlight()
            else:
                self.draw_fixcross()
        pygame.display.update()


    def show_trafficlight(self):
        this_trafficlight = self.trafficlight_image[self.this_trafficlight_index]
        image_size = this_trafficlight.get_size()
        self.screen.blit(this_trafficlight,((self.screenSize[0]/2-image_size[0]/2),(self.screenSize[1]/2-image_size[1]/2)))


    def render_text(self, text):
        disp_text = self.font_text.render(text,0,self.text_color)
        textsize = disp_text.get_rect()
        self.screen.blit(disp_text, (self.screen_center[0] - textsize[2]/2, self.screen_center[1] - textsize[3]/2))
    
    
    def draw_fixcross(self):
        disp_text = self.font_char.render('+',0,self.char_color)
        textsize = disp_text.get_rect()
        self.screen.blit(disp_text, (self.screen_center[0] - textsize[2]/2, self.screen_center[1] - textsize[3]/2))
    
         
    def load_images(self):
        path = os.path.dirname(globals()["__file__"])
        self.trafficlight_image = [None,None,None,None]
        for c, color in enumerate(self.trafficlight_states):
            self.trafficlight_image[c] = pygame.image.load(os.path.join(path, 'tl_' + color + '.png')).convert_alpha()

   
    def send_parallel_log(self, event):
        self.send_parallel(event)
        self.log(self.marker_identifier[event])
    
    
    def log(self,print_str):
        now = pygame.time.get_ticks()
        print '[%4.2f sec] %s' % (now/1000.0,print_str)



if __name__ == "__main__":
   fb = TrafficLight_decide()
   fb.on_init()
   fb.on_play()
