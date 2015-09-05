class @WebMidi

  WebMidi::Status = {
    Initializing: 'Initializing MIDI...',
    NotSupported: 'Web MIDI is not supported in this browser.',
    ConnectionFailed: 'Could not connect to MIDI peripherals.',
    Connected: 'Connection succeeded.',
    Receiving: 'Actively receiving MIDI messages.'
  }

  WebMidi::EventType = {
    Undefined: 'Undefined Event',
    NoteOn: 'Note On',
    NoteOff: 'Note Off',
    CC: 'CC',
    Clock: 'Clock',
    SysEx: 'SysEx',
  }

  class WebMidi::Event
    constructor: (type, value, note, octave, velocity) ->
      @type = type ? @EventType.Undefined
      @value = value ? -1
      @note = note ? ''
      @octave = octave ? -1
      @velocity = velocity ? -1

  log: (text) ->
    console.log("WebMIDI: #{text}")

  constructor: (options = {}) ->
    @options = options
    requirejs.config({
      baseUrl : "assets/javascript/zmidi/",
      urlArgs : "bust=" + Date.now()
    });
    require [ "zMIDI", "zMIDIEvent", "MIDINotes" ],
      (zMIDI, zMIDIEvent, MIDINotes ) =>
        @zmidi = zMIDI
        @zmidiEvent = zMIDIEvent
        @midiNotes = MIDINotes
        @status = @Status.Initializing
        @onNotSupported if not @zmidi.isSupported()
        @zmidi.connect(@onConnectSuccess, @onConnectFailure)

  onNotSupported: =>
    @status = @Status.NotSupported
    @log("Status Change: #{@status}")
    $(@).trigger('notSupported')

  onConnectSuccess: =>
    @status = @Status.Connected
    @log("Status Change: #{@status}")
    $(@).trigger('connectionSuccessful')
    @addMessageEventHandlers()

  onConnectFailure: =>
    @status = @Status.ConnectionFailed
    @log("Status Change: #{@status}")
    $(@).trigger('connectionFailed')

  addMessageEventHandlers: =>
    inputs = @zmidi.getInChannels()
    @onConnectFailure() if inputs.length == 0
    inputs.forEach( (input, whichInput) =>
      @log("Enumerating Device #{whichInput}: #{input.manufacturer} #{input.name}")
      @zmidi.addMessageListener(whichInput, @onEventFired)
      setTimeout ( =>
          @zmidi.removeMessageListener(whichInput)
        ), 5000 if @options.safeMode
    )

  onEventFired: (event) =>
    switch event.type
      when @zmidiEvent.NOTE_ON
        pitch = @midiNotes.getPitchByNoteNumber(event.value)
        note = new @Event(@EventType.NoteOn, event.value, pitch.note, pitch.octave, event.velocity)
        $(@).trigger('noteOn', note)
      when @zmidiEvent.NOTE_OFF
        pitch = @midiNotes.getPitchByNoteNumber(event.value)
        note = new @Event(@EventType.NoteOff, event.value, pitch.note, pitch.octave, event.velocity)
        $(@).trigger('noteOff', note)
      when @zmidiEvent.CONTROL_CHANGE
        note = new @Event(@EventType.CC, undefined, undefined, undefined, event.velocity)
        $(@).trigger('cc', note)