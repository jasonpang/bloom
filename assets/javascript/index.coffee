editor = CodeMirror.fromTextArea(document.getElementById('editor'), {
  lineNumbers: true,
  fixedGutter: true,
  matchBrackets: true,
  indentUnit: 4,
  tabSize: 4,
  indentWithTabs: true,
  mode: 'stex',
})

window.midiIo = new MidiIo({
  safeMode: false,
  logging: true,
})

window.track = new MidiTrack('Test Track', 4, 4, 120, {})

window.trackProcessor = new MidiTrackProcessor({
  firstNoteTimestampBecomesTrackStartTimestamp: true,
  quantize: false,
  quantizeLimit: 16 # 16th notes
})

$(midiIo).on('noteOn', (jqueryEvent, event) ->
  if track.state == track.RecordState.Initialized
    track.startRecording()
  console.log(event.toString())
  track.recordEvent(event)
)

$(midiIo).on('noteOff', (jqueryEvent, event) ->
  console.log(event.toString())
  track.recordEvent(event)
)

$(midiIo).on('cc', (jqueryEvent, event) ->
  console.log(event.toString())
  if track.state == track.RecordState.Recording
    track.stopRecording()
    window.processedTrack = window.trackProcessor.processTrack(track)
  console.log(track)
)