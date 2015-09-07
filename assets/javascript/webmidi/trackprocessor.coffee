class @MidiTrackProcessor
  constructor: (options = {}) ->
    @options = options

  processTrack: (originalTrack) ->
    track = JSON.parse(JSON.stringify(originalTrack)) # Operate on a clone of the original object
    if (@options.firstNoteTimestampBecomesTrackStartTimestamp)
      firstEventTimestamp = track.orderedTimestampList[0]
      trackStartTimestamp = track.start
      timestampDelta = firstEventTimestamp - trackStartTimestamp
      for originalTimestamp, index in track.orderedTimestampList
        originalNote = track.notes[originalTimestamp]
        originalNote.occurred -= timestampDelta
        originalNote.duration -= timestampDelta
        delete track.notes[originalTimestamp]
        track.notes[originalTimestamp - timestampDelta] = originalNote
        track.orderedTimestampList[index] -= timestampDelta
    @quantizeLengths() if @options.quantize
    @calculateNoteDurations(track)
    track

  calculateNoteDurations: (track) ->
    # The length one quarter note should be is 60 / bpm
    beatLength = 60 / track.bpm
    beatType = 4; # A quarter note's reciprocal value
    for timestamp, index in track.orderedTimestampList
      noteEvent = track.notes[timestamp]
      noteType = beatType * beatLength / (noteEvent.duration / 1000) # e.g. 8, for eigth notes
      noteEvent.duration_notation = noteType
      console.log(noteEvent.duration_notation)

  quantizeLengths: (track) ->
    # The length one quarter note should be is 60 / bpm
    beatLength = 60 / @options.bpm


