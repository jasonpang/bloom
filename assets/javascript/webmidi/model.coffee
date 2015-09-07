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

  constructor: (name, timeSignatureBeats, timeSignatureBar, bpm, options = {}) ->
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
    @notes = {} # Timestamp -> MidiNote / MidiChord
    @noteEventMap = {} # Timestamp -> MidiIo::Event
    @noteEventList = [] # Temporary queue to store NoteOn and subsequent NoteOff event; each slot cleared after NoteOff
    @orderedTimestampList = [] # Ordered list of timestamps
    for index in [MidiTrack.Vars.LowestNoteValue .. MidiTrack.Vars.HighestNoteValue]
      @noteEventList.push []


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
    if midiIoEvent.type == MidiIo.EventType.NoteOn
      @noteEventList[midiIoEvent.value].push(midiIoEvent)
      @noteEventMap[midiIoEvent.occurred] = midiIoEvent
      @orderedTimestampList.push(midiIoEvent.occurred)
    else if midiIoEvent.type == MidiIo.EventType.NoteOff
      noteOnEvent = @noteEventList[midiIoEvent.value].pop()
      noteOffEvent = midiIoEvent
      @notes[noteOnEvent.occurred] = new MidiNote(
        noteOnEvent.value,
        noteOnEvent.note,
        noteOnEvent.octave,
        noteOnEvent.velocity,
        noteOnEvent.occurred,
        noteOffEvent.occurred - noteOnEvent.occurred,
      )

  save: ->
    JSON.stringify(@)

  @restore: (jsonString) ->
    JSON.parse(jsonString)


class @MidiNote
  constructor: (value, note, octave, velocity, occurred, duration) ->
    @value = value ? -1
    @note = note ? ''
    @octave = octave ? -1
    @velocity = velocity ? -1
    @occurred = occurred
    @duration = duration

  toString: ->
    return "#{@note}#{@octave} [#{@velocity}] @ #{duration} ms"

class @MidiChord
  constructor: (notes) ->
    @notes = notes