class @MidiTrack
  MidiTrack::RecordState = {
    Initialized: 'Initialized',
    Recording: 'Recording',
    Stopped: 'Stopped'
  }

  @Vars: {
    LowestNoteValue: 21,
    HighestNoteValue: 108
  }

  constructor: (midiIo, name, timeSignatureBeats, timeSignatureBar, bpm, options = {}) ->
    @midiIo = midiIo
    @name = name ? 'Unnamed Track'
    @state = MidiTrack::RecordState.Initialized
    @timeSignatureBeats = timeSignatureBeats ? -1
    @timeSignatureBar = timeSignatureBar ? -1
    @start = -1
    @end = -1
    @duration = -1
    @bpm = bpm
    @canRecord = true
    @options = options
    @notes = []
    @noteEventStack = []
    for index in [MidiTrack.Vars.LowestNoteValue .. MidiTrack.Vars.HighestNoteValue]
      @noteEventStack.push []


  startRecording: ->
    if !@canRecord
      throw 'Cannot begin recording MIDI track because it has already been recorded.'
    @state = MidiTrack::RecordState.Recording
    @start = window.performance.timing.navigationStart + window.performance.now()

  stopRecording: ->
    @canRecord = false
    @end = window.performance.timing.navigationStart + window.performance.now()
    @duration = @end - @start
    @state = MidiTrack::RecordState.Stopped

  recordEvent: (midiIoEvent) ->
    # Each depressed note must be lifted before the same note can be re-triggered
    if midiIoEvent.type == @midiIo.EventType.NoteOn
      @noteEventStack[midiIoEvent.value].push(midiIoEvent)
    else if midiIoEvent.type == @midiIo.EventType.NoteOff
      noteOnEvent = @noteEventStack[midiIoEvent.value].pop()
      noteOffEvent = midiIoEvent
      @notes.push(new MidiNote(
        noteOnEvent.value,
        noteOnEvent.note,
        noteOnEvent.octave,
        noteOnEvent.velocity,
        noteOnEvent.at,
        noteOffEvent.at - noteOnEvent.at
      ))

  toJson: ->
    JSON.stringify(@)

  @fromJson: (jsonString) ->
    JSON.parse(jsonString)


class @MidiNote
  constructor: (value, note, octave, velocity, at, duration) ->
    @value = value ? -1
    @note = note ? ''
    @octave = octave ? -1
    @velocity = velocity ? -1
    @at = at
    @duration = duration

  toString: ->
    return "#{@note}#{@octave} [#{@velocity}] @ #{duration} ms"

class @MidiChord
  constructor: (notes) ->
    @notes = notes