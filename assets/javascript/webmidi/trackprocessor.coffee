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
    @quantizeLengths()
    track

  quantizeLengths: (track) ->

