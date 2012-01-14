;;; ----------------------------------------------------------------------------
;;; gdk.device.lisp
;;; 
;;; This file contains code from a fork of cl-gtk2.
;;; See http://common-lisp.net/project/cl-gtk2/
;;; 
;;; The documentation has been copied from the GTK 2.2.2 Reference Manual
;;; See http://www.gtk.org.
;;; 
;;; Copyright (C) 2009 - 2011 Kalyanov Dmitry
;;; Copyright (C) 2011 - 2012 Dr. Dieter Kaiser
;;; 
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU Lesser General Public License for Lisp
;;; as published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version and with a preamble to
;;; the GNU Lesser General Public License that clarifies the terms for use
;;; with Lisp programs and is referred as the LLGPL.
;;; 
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU Lesser General Public License for more details.
;;; 
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this program and the preamble to the Gnu Lesser
;;; General Public License.  If not, see <http://www.gnu.org/licenses/>
;;; and <http://opensource.franz.com/preamble.html>.
;;; ----------------------------------------------------------------------------
;;;
;;; Input Devices
;;; 
;;; Functions for handling extended input devices
;;; 
;;; Synopsis
;;; 
;;;     GdkDevice;
;;;     GdkInputSource;
;;;     GdkInputMode;
;;;     GdkDeviceKey;
;;;     GdkDeviceAxis;
;;;     GdkAxisUse;
;;;     gdk_devices_list
;;;     gdk_device_get_name
;;;     gdk_device_set_source
;;;     gdk_device_get_source
;;;     gdk_device_set_mode
;;;     gdk_device_get_mode
;;;     gdk_device_set_key
;;;     gdk_device_get_key
;;;     gdk_device_set_axis_use
;;;     gdk_device_get_axis_use
;;;     gdk_device_get_core_pointer
;;;     
;;;     gdk_device_get_state
;;;     gdk_device_get_history
;;;     gdk_device_free_history
;;;     GdkTimeCoord
;;;     gdk_device_get_axis
;;;     gdk_device_get_n_axes
;;;     
;;;     gdk_input_set_extension_events
;;;     GdkExtensionMode;
;;; 
;;; Description
;;; 
;;; In addition to the normal keyboard and mouse input devices, GTK+ also 
;;; contains support for extended input devices. In particular, this support is 
;;; targeted at graphics tablets. Graphics tablets typically return sub-pixel 
;;; positioning information and possibly information about the pressure and
;;; tilt of the stylus. Under X, the support for extended devices is done
;;; through the XInput extension.
;;; 
;;; Because handling extended input devices may involve considerable overhead, 
;;; they need to be turned on for each GdkWindow individually using 
;;; gdk_input_set_extension_events(). (Or, more typically, for GtkWidgets,
;;; using gtk_widget_set_extension_events()). As an additional complication,
;;; depending on the support from the windowing system, its possible that a
;;; normal mouse cursor will not be displayed for a particular extension device.
;;; If an application does not want to deal with displaying a cursor itself, it
;;; can ask only to get extension events from devices that will display a
;;; cursor, by passing the GDK_EXTENSION_EVENTS_CURSOR value to
;;; gdk_input_set_extension_events(). Otherwise, the application must retrieve
;;; the device information using gdk_devices_list(), check the has_cursor field,
;;; and, if it is FALSE, draw a cursor itself when it receives motion events.
;;; 
;;; Each pointing device is assigned a unique integer ID; events from a 
;;; particular device can be identified by the deviceid field in the event 
;;; structure. The events generated by pointer devices have also been extended
;;; to contain pressure, xtilt and ytilt fields which contain the extended
;;; information reported as additional valuators from the device. The pressure
;;; field is a a double value ranging from 0.0 to 1.0, while the tilt fields
;;; are double values ranging from -1.0 to 1.0. (With -1.0 representing the
;;; maximum tilt to the left or up, and 1.0 representing the maximum tilt to
;;; the right or down.)
;;; 
;;; One additional field in each event is the source field, which contains an 
;;; enumeration value describing the type of device; this currently can be one
;;; of GDK_SOURCE_MOUSE, GDK_SOURCE_PEN, GDK_SOURCE_ERASER, or
;;; GDK_SOURCE_CURSOR. This field is present to allow simple applications to
;;; (for instance) delete when they detect eraser devices without having to
;;; keep track of complicated per-device settings.
;;; 
;;; Various aspects of each device may be configured. The configuration of 
;;; devices is queried using gdk_devices_list(). Each device must be activated 
;;; using gdk_device_set_mode(), which also controls whether the device's range
;;; is mapped to the entire screen or to a single window. The mapping of the
;;; valuators of the device onto the predefined valuator types is set using 
;;; gdk_device_set_axis_use(). And the source type for each device can be set
;;; with gdk_device_set_source().
;;; 
;;; Devices may also have associated keys or macro buttons. Such keys can be 
;;; globally set to map into normal X keyboard events. The mapping is set using 
;;; gdk_device_set_key().
;;; 
;;; The interfaces in this section will most likely be considerably modified in 
;;; the future to accomodate devices that may have different sets of additional 
;;; valuators than the pressure xtilt and ytilt.
;;; ----------------------------------------------------------------------------

(in-package :gdk)

;;; ----------------------------------------------------------------------------
;;; enum GdkInputSource
;;; 
;;; typedef enum
;;; {
;;;   GDK_SOURCE_MOUSE,
;;;   GDK_SOURCE_PEN,
;;;   GDK_SOURCE_ERASER,
;;;   GDK_SOURCE_CURSOR
;;; } GdkInputSource;
;;; 
;;; An enumeration describing the type of an input device in general terms.
;;; 
;;; GDK_SOURCE_MOUSE
;;;     the device is a mouse. (This will be reported for the core pointer, 
;;;     even if it is something else, such as a trackball.)
;;; 
;;; GDK_SOURCE_PEN
;;;     the device is a stylus of a graphics tablet or similar device.
;;; 
;;; GDK_SOURCE_ERASER
;;;     the device is an eraser. Typically, this would be the other end of a 
;;;     stylus on a graphics tablet.
;;; 
;;; GDK_SOURCE_CURSOR
;;;     the device is a graphics tablet "puck" or similar device.
;;; ----------------------------------------------------------------------------

(define-g-enum "GdkInputSource" gdk-input-source
  (:export t
   :type-initializer "gdk_input_source_get_type")
  (:mouse 0)
  (:pen 1)
  (:eraser 2)
  (:cursor 3))

;;; ----------------------------------------------------------------------------
;;; enum GdkInputMode
;;; 
;;; typedef enum
;;; {
;;;   GDK_MODE_DISABLED,
;;;   GDK_MODE_SCREEN,
;;;   GDK_MODE_WINDOW
;;; } GdkInputMode;
;;; 
;;; An enumeration that describes the mode of an input device.
;;; 
;;; GDK_MODE_DISABLED
;;;     the device is disabled and will not report any events.
;;; 
;;; GDK_MODE_SCREEN
;;;     the device is enabled. The device's coordinate space maps to the 
;;;     entire screen.
;;; 
;;; GDK_MODE_WINDOW
;;;     the device is enabled. The device's coordinate space is mapped to a 
;;;     single window. The manner in which this window is chosen is undefined,
;;;     but it will typically be the same way in which the focus window for key
;;;     events is determined.
;;; ----------------------------------------------------------------------------

(define-g-enum "GdkInputMode" gdk-input-mode
  (:export t
   :type-initializer "gdk_input_mode_get_type")
  (:disabled 0)
  (:screen 1)
  (:window 2))

;;; ----------------------------------------------------------------------------
;;; enum GdkAxisUse
;;; 
;;; typedef enum
;;; {
;;;   GDK_AXIS_IGNORE,
;;;   GDK_AXIS_X,
;;;   GDK_AXIS_Y,
;;;   GDK_AXIS_PRESSURE,
;;;   GDK_AXIS_XTILT,
;;;   GDK_AXIS_YTILT,
;;;   GDK_AXIS_WHEEL,
;;;   GDK_AXIS_LAST
;;; } GdkAxisUse;
;;; 
;;; An enumeration describing the way in which a device axis (valuator) maps 
;;; onto the predefined valuator types that GTK+ understands.
;;; 
;;; GDK_AXIS_IGNORE
;;;     the axis is ignored.
;;; 
;;; GDK_AXIS_X
;;;     the axis is used as the x axis.
;;; 
;;; GDK_AXIS_Y
;;;     the axis is used as the y axis.
;;; 
;;; GDK_AXIS_PRESSURE
;;;     the axis is used for pressure information.
;;; 
;;; GDK_AXIS_XTILT
;;;     the axis is used for x tilt information.
;;; 
;;; GDK_AXIS_YTILT
;;;     the axis is used for x tilt information.
;;; 
;;; GDK_AXIS_WHEEL
;;;     the axis is used for wheel information.
;;; 
;;; GDK_AXIS_LAST
;;;     a constant equal to the numerically highest axis value.
;;; ----------------------------------------------------------------------------

(define-g-enum "GdkAxisUse" gdk-axis-use
  (:export t
   :type-initializer "gdk_axis_use_get_type")
  (:ignore 0)
  (:x 1)
  (:y 2)
  (:pressure 3)
  (:xtilt 4)
  (:ytilt 5)
  (:wheel 6)
  (:last 7))

;;; ----------------------------------------------------------------------------
;;; struct GdkDeviceAxis
;;; 
;;; struct GdkDeviceAxis {
;;;   GdkAxisUse use;
;;;   gdouble    min;
;;;   gdouble    max;
;;; };
;;; 
;;; The GdkDeviceAxis structure contains information about the range and 
;;; mapping of a device axis.
;;; 
;;; GdkAxisUse use;
;;;     specifies how the axis is used.
;;; 
;;; gdouble min;
;;;     the minimal value that will be reported by this axis.
;;; 
;;; gdouble max;
;;;     the maximal value that will be reported by this axis.
;;; ----------------------------------------------------------------------------

(define-g-boxed-cstruct gdk-device-axis nil
  (use gdk-axis-use)
  (min :double)
  (max :double))

;;; ----------------------------------------------------------------------------
;;; struct GdkDeviceKey
;;; 
;;; struct GdkDeviceKey {
;;;   guint keyval;
;;;   GdkModifierType modifiers;
;;; };
;;; 
;;; The GdkDeviceKey structure contains information about the mapping of one 
;;; device macro button onto a normal X key event. It has the following fields:
;;; 
;;; guint keyval;
;;;     the keyval to generate when the macro button is pressed. If this is 0, 
;;;     no keypress will be generated.
;;; 
;;; GdkModifierType modifiers;
;;;     the modifiers set for the generated key event.
;;; ----------------------------------------------------------------------------

(define-g-boxed-cstruct gdk-device-key nil
  (keyval :uint)
  (modifiers gdk-modifier-type))

;;; ----------------------------------------------------------------------------
;;; struct GdkDevice
;;; 
;;; struct GdkDevice {
;;;   GObject parent_instance;
;;;   /* All fields are read-only */
;;;   
;;;   gchar *GSEAL (name);
;;;   GdkInputSource GSEAL (source);
;;;   GdkInputMode GSEAL (mode);
;;;   gboolean GSEAL (has_cursor); /* TRUE if the X pointer follows device 
;;;                                   motion */
;;;   
;;;   gint GSEAL (num_axes);
;;;   GdkDeviceAxis *GSEAL (axes);
;;;   
;;;   gint GSEAL (num_keys);
;;;   GdkDeviceKey *GSEAL (keys);
;;; };
;;; 
;;; A GdkDevice structure contains a detailed description of an extended input
;;; device. All fields are read-only; but you can use gdk_device_set_source(),
;;; gdk_device_set_mode(), gdk_device_set_key() and gdk_device_set_axis_use()
;;; to configure various aspects of the device.
;;; 
;;; GObject parent_instance;
;;;     the parent instance
;;; ----------------------------------------------------------------------------

(defcstruct %gdk-device
  (parent-instance gobject::%g-object)
  (name (:string :free-from-foreign nil))
  (source gdk-input-source)
  (mode gdk-input-mode)
  (has-cursor :boolean)
  (num-axes :int)
  (axes :pointer)
  (num-keys :int)
  (keys :pointer))

(defun %gdk-device-has-cursor (device)
  (foreign-slot-value (pointer device) '%gdk-device 'has-cursor))

(defun %gdk-device-n-keys (device)
  (foreign-slot-value (pointer device) '%gdk-device 'num-keys))


(defun %gdk-device-axes (device)
  (let ((n (foreign-slot-value (pointer device) '%gdk-device 'num-axes))
        (axes (foreign-slot-value (pointer device) '%gdk-device 'axes)))
    (iter (for i from 0 below n)
          (for axis = (convert-from-foreign
                        (inc-pointer axes (* i
                                             (foreign-type-size 'gdk-device-axis-cstruct)))
                       '(g-boxed-foreign gdk-device-axis)))
          (collect axis))))

(defun %gdk-device-keys (device)
  (let ((n (foreign-slot-value (pointer device) '%gdk-device 'num-keys))
        (keys (foreign-slot-value (pointer device) '%gdk-device 'keys)))
    (iter (for i from 0 below n)
          (for key = (convert-from-foreign
                      (inc-pointer keys (* i
                                           (foreign-type-size 'gdk-device-key-cstruct)))
                      '(g-boxed-foreign gdk-device-key)))
          (collect key))))

(define-g-object-class "GdkDevice" gdk-device
  (:superclass g-object
   :export t
   :interfaces nil
   :type-initializer "gdk_device_get_type")
  ((:cffi name gdk-device-name :string
          %gdk-device-name nil)
   (:cffi source gdk-device-source gdk-input-source
          %gdk-device-source "gdk_device_set_source")
   (:cffi mode gdk-device-mode gdk-input-mode
          %gdk-device-mode gdk_device_set_mode)
   (:cffi has-cursor gdk-device-has-cursor :boolean
          %gdk-device-has-cursor nil)
   (:cffi n-axes gdk-device-n-axes :int
          %gdk-device-n-axes nil)
   (:cffi axes gdk-device-axes nil
          %gdk-device-axes nil)
   (:cffi keys gdk-device-keys nil
          %gdk-device-keys nil)
   (:cffi n-keys gdk-device-n-keys nil
     %gdk-device-n-keys nil)))

(defmethod print-object ((object gdk-device) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~A (~A, ~A)" (gdk-device-name object)
                                 (gdk-device-source object)
                                 (gdk-device-mode object))))

;;; ----------------------------------------------------------------------------
;;; gdk_devices_list ()
;;; 
;;; GList * gdk_devices_list (void);
;;; 
;;; Returns the list of available input devices for the default display. The
;;; list is statically allocated and should not be freed.
;;; 
;;; Returns :
;;;     a list of GdkDevice
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_devices_list" gdk-devices-list)
    (g-list (g-object gdk-device) :free-from-foreign nil))

(export 'gdk-devices-list)

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_name ()
;;; 
;;; const gchar * gdk_device_get_name (GdkDevice *device);
;;; 
;;; Determines the name of the device.
;;; 
;;; device :
;;;     a GdkDevice
;;; 
;;; Returns :
;;;     a name
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

(defun %gdk-device-name (device)
  (foreign-slot-value (pointer device) '%gdk-device 'name))

;;; ----------------------------------------------------------------------------
;;; gdk_device_set_source ()
;;; 
;;; void gdk_device_set_source (GdkDevice *device, GdkInputSource source);
;;; 
;;; Sets the source type for an input device.
;;; 
;;; device :
;;;     a GdkDevice.
;;; 
;;; source :
;;;     the source type.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_source ()
;;; 
;;; GdkInputSource gdk_device_get_source (GdkDevice *device);
;;; 
;;; Determines the type of the device.
;;; 
;;; device :
;;;     a GdkDevice
;;; 
;;; Returns :
;;;     a GdkInputSource
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

(defun %gdk-device-source (device)
  (foreign-slot-value (pointer device) '%gdk-device 'source))

;;; ----------------------------------------------------------------------------
;;; gdk_device_set_mode ()
;;; 
;;; gboolean gdk_device_set_mode (GdkDevice *device, GdkInputMode mode);
;;; 
;;; Sets a the mode of an input device. The mode controls if the device is 
;;; active and whether the device's range is mapped to the entire screen or to
;;; a single window.
;;; 
;;; device :
;;;     a GdkDevice.
;;; 
;;; mode :
;;;     the input mode.
;;; 
;;; Returns :
;;;     TRUE if the mode was successfully changed.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_device_set_mode" gdk-device-set-mode) :boolean
  (device (g-object gdk-device))
  (mode gdk-input-mode))

(export 'gdk-device-set-mode)

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_mode ()
;;; 
;;; GdkInputMode gdk_device_get_mode (GdkDevice *device);
;;; 
;;; Determines the mode of the device.
;;; 
;;; device :
;;; 	a GdkDevice
;;; 
;;; Returns :
;;; 	a GdkInputSource
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

(defun %gdk-device-mode (device)
  (foreign-slot-value (pointer device) '%gdk-device 'mode))

;;; ----------------------------------------------------------------------------
;;; gdk_device_set_key ()
;;; 
;;; void gdk_device_set_key (GdkDevice *device,
;;;                          guint index_,
;;;                          guint keyval,
;;;                          GdkModifierType modifiers);
;;; 
;;; Specifies the X key event to generate when a macro button of a device is
;;; pressed.
;;; 
;;; device :
;;; 	a GdkDevice.
;;; 
;;; index_ :
;;; 	the index of the macro button to set.
;;; 
;;; keyval :
;;; 	the keyval to generate.
;;; 
;;; modifiers :
;;; 	the modifiers to set.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk-device-set-key" gdk-device-set-key) :void
  (device (g-object gdk-device))
  (index :uint)
  (keyval :uint)
  (modifiers gdk-modifier-type))

(export 'gdk-device-set-key)

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_key ()
;;; 
;;; void gdk_device_get_key (GdkDevice *device,
;;;                          guint index,
;;;                          guint *keyval,
;;;                          GdkModifierType *modifiers);
;;; 
;;; If index has a valid keyval, this function will fill in keyval and
;;; modifiers with the keyval settings.
;;; 
;;; device :
;;; 	a GdkDevice.
;;; 
;;; index :
;;; 	the index of the macro button to get.
;;; 
;;; keyval :
;;; 	return value for the keyval.
;;; 
;;; modifiers :
;;; 	return value for modifiers.
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_device_set_axis_use ()
;;; 
;;; void gdk_device_set_axis_use (GdkDevice *device,
;;;                               guint index_,
;;;                               GdkAxisUse use);
;;; 
;;; Specifies how an axis of a device is used.
;;; 
;;; device :
;;; 	a GdkDevice.
;;; 
;;; index_ :
;;; 	the index of the axis.
;;; 
;;; use :
;;; 	specifies how the axis is used.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_device_set_axis_use" gdk-device-set-axis-use) :void
  (device (g-object gdk-device))
  (index :uint)
  (use gdk-axis-use))

(export 'gdk-device-set-axis-use)

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_axis_use ()
;;; 
;;; GdkAxisUse gdk_device_get_axis_use (GdkDevice *device, guint index);
;;; 
;;; Returns the axis use for index.
;;; 
;;; device :
;;; 	a GdkDevice.
;;; 
;;; index :
;;; 	the index of the axis.
;;; 
;;; Returns :
;;; 	a GdkAxisUse specifying how the axis is used.
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_core_pointer ()
;;; 
;;; GdkDevice * gdk_device_get_core_pointer (void);
;;; 
;;; Returns the core pointer device for the default display.
;;; 
;;; Returns :
;;; 	the core pointer device; this is owned by the display and should not
;;;     be freed.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_device_get_core_pointer" gdk-device-get-core-pointer)
    (g-object gdk-device))

(export 'gdk-device-get-core-pointer)

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_state ()
;;; 
;;; void gdk_device_get_state (GdkDevice *device,
;;;                            GdkWindow *window,
;;;                            gdouble *axes,
;;;                            GdkModifierType *mask);
;;; 
;;; Gets the current state of a device.
;;; 
;;; device :
;;; 	a GdkDevice.
;;; 
;;; window :
;;; 	a GdkWindow.
;;; 
;;; axes :
;;; 	an array of doubles to store the values of the axes of device in,
;;;     or NULL.
;;; 
;;; mask :
;;; 	location to store the modifiers, or NULL.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_device_get_state" %gdk-device-get-state) :void
  (device (g-object gdk-device))
  (window (g-object gdk-window))
  (axes (:pointer :double))
  (mask (:pointer gdk-modifier-type)))

(defun gdk-device-get-state (device window)
  (with-foreign-objects ((axes :double (%gdk-device-n-axes device))
                         (mask 'gdk-modifier-type))
    (%gdk-device-get-state device window axes mask)
    (values (iter (for i from 0 below (%gdk-device-n-axes device))
                  (collect (mem-aref axes :double i)))
            (mem-ref mask 'gdk-modifier-type))))

(export 'gdk-device-get-state)

;;; ----------------------------------------------------------------------------
;;; struct GdkTimeCoord
;;; 
;;; struct GdkTimeCoord {
;;;   guint32 time;
;;;   gdouble axes[GDK_MAX_TIMECOORD_AXES];
;;; };
;;; 
;;; The GdkTimeCoord structure stores a single event in a motion history. It
;;; contains the following fields:
;;; 
;;; guint32 time;
;;; 	The timestamp for this event.
;;; 
;;; gdouble axes[GDK_MAX_TIMECOORD_AXES];
;;; 	the values of the device's axes.
;;; ----------------------------------------------------------------------------

(define-g-boxed-cstruct gdk-time-coord nil
  (time :uint32)
  (axes :double :count 128))

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_history ()
;;; 
;;; gboolean gdk_device_get_history (GdkDevice *device,
;;;                                  GdkWindow *window,
;;;                                  guint32 start,
;;;                                  guint32 stop,
;;;                                  GdkTimeCoord ***events,
;;;                                  gint *n_events);
;;; 
;;; Obtains the motion history for a device; given a starting and ending
;;; timestamp, return all events in the motion history for the device in the
;;; given range of time. Some windowing systems do not support motion history,
;;; in which case, FALSE will be returned. (This is not distinguishable from
;;; the case where motion history is supported and no events were found.)
;;; 
;;; device :
;;; 	a GdkDevice
;;; 
;;; window :
;;; 	the window with respect to which which the event coordinates will
;;;     be reported
;;; 
;;; start :
;;; 	starting timestamp for range of events to return
;;; 
;;; stop :
;;; 	ending timestamp for the range of events to return
;;; 
;;; events :
;;; 	location to store a newly-allocated array of GdkTimeCoord, or NULL.
;;; 
;;; n_events :
;;; 	location to store the length of events, or NULL
;;; 
;;; Returns :
;;; 	TRUE if the windowing system supports motion history and at least
;;;     one event was found.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_device_get_history" %gdk-device-get-history) :boolean
  (device (g-object gdk-device))
  (window (g-object gdk-window))
  (start :uint32)
  (stop :uint32)
  (events (:pointer (:pointer (:pointer gdk-time-coord-cstruct))))
  (n-events (:pointer :int)))

(defun gdk-device-get-history (device window start stop)
  (with-foreign-objects ((events :pointer) (n-events :int))
    (when (%gdk-device-get-history device window start stop events n-events)
      (prog1
        (iter (with events-ar = (mem-ref events :pointer))
              (for i from 0 below (mem-ref n-events :int))
              (for coord = (mem-aref events-ar
                                     '(g-boxed-foreign gdk-time-coord)
                                     i))
              (collect coord))
        (gdk-device-free-history (mem-ref events :pointer)
                                 (mem-ref n-events :int))))))

(export 'gdk-device-get-history)

;;; ----------------------------------------------------------------------------
;;; gdk_device_free_history ()
;;; 
;;; void gdk_device_free_history (GdkTimeCoord **events, gint n_events);
;;; 
;;; Frees an array of GdkTimeCoord that was returned by
;;; gdk_device_get_history().
;;; 
;;; events :
;;; 	an array of GdkTimeCoord.
;;; 
;;; n_events :
;;; 	the length of the array.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_device_free_history" gdk-device-free-history) :void
  (events (:pointer (:pointer gdk-time-coord-cstruct)))
  (n-events :int))

(export 'gdk-device-free-history)

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_axis ()
;;; 
;;; gboolean gdk_device_get_axis (GdkDevice *device,
;;;                               gdouble *axes,
;;;                               GdkAxisUse use,
;;;                               gdouble *value);
;;; 
;;; Interprets an array of double as axis values for a given device, and
;;; locates the value in the array for a given axis use.
;;; 
;;; device :
;;; 	a GdkDevice
;;; 
;;; axes :
;;; 	pointer to an array of axes
;;; 
;;; use :
;;; 	the use to look for
;;; 
;;; value :
;;; 	location to store the found value.
;;; 
;;; Returns :
;;; 	TRUE if the given axis use was found, otherwise FALSE
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_device_get_axis" %gdk-device-get-axis) :boolean
  (device (g-object gdk-device))
  (axes (:pointer :double))
  (use gdk-axis-use)
  (value (:pointer :double)))

(defun gdk-device-get-axis (device axes axis-use)
  (assert (= (%gdk-device-n-axes device) (length axes)))
  (with-foreign-objects ((axes-ar :double (%gdk-device-n-axes device))
                         (value :double))
    (let ((i 0))
      (map nil
           (lambda (v)
             (setf (mem-aref axes-ar :double i) v)
             (incf i))
           axes))
    (when (%gdk-device-get-axis device axes-ar axis-use value)
      (mem-ref value :double))))

(export 'gdk-device-get-axis)

;;; ----------------------------------------------------------------------------
;;; gdk_device_get_n_axes ()
;;; 
;;; gint gdk_device_get_n_axes (GdkDevice *device);
;;; 
;;; Gets the number of axes of a device.
;;; 
;;; device :
;;; 	a GdkDevice.
;;; 
;;; Returns :
;;; 	the number of axes of device
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

(defun %gdk-device-n-axes (device)
  (foreign-slot-value (pointer device) '%gdk-device 'num-axes))

;;; ----------------------------------------------------------------------------
;;; enum GdkExtensionMode
;;; 
;;; typedef enum
;;; {
;;;   GDK_EXTENSION_EVENTS_NONE,
;;;   GDK_EXTENSION_EVENTS_ALL,
;;;   GDK_EXTENSION_EVENTS_CURSOR
;;; } GdkExtensionMode;
;;; 
;;; An enumeration used to specify which extension events are desired for a
;;; particular widget.
;;; 
;;; GDK_EXTENSION_EVENTS_NONE
;;; 	no extension events are desired.
;;; 
;;; GDK_EXTENSION_EVENTS_ALL
;;; 	all extension events are desired.
;;; 
;;; GDK_EXTENSION_EVENTS_CURSOR
;;; 	extension events are desired only if a cursor will be displayed for
;;;     the device.
;;; ----------------------------------------------------------------------------

(define-g-enum "GdkExtensionMode" gdk-extension-mode
  (:export t
   :type-initializer "gdk_extension_mode_get_type")
  (:none 0)
  (:all 1)
  (:cursor 2))

;;; ----------------------------------------------------------------------------
;;; gdk_input_set_extension_events ()
;;; 
;;; void gdk_input_set_extension_events (GdkWindow *window,
;;;                                      gint mask,
;;;                                      GdkExtensionMode mode);
;;; 
;;; Turns extension events on or off for a particular window, and specifies the
;;; event mask for extension events.
;;; 
;;; window :
;;; 	a GdkWindow.
;;; 
;;; mask :
;;; 	the event mask
;;; 
;;; mode :
;;; 	the type of extension events that are desired.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_input_set_extension_events" gdk-input-set-extension-events) :void
  (window (g-object gdk-window))
  (mask :int)
  (mode gdk-extension-mode))

(export 'gdk-input-set-extension-events)

;;; --- End of file gdk.device.lisp --------------------------------------------

