class @MidiTests
  @errors = []

  class MidiTests::FirstNoteTimestampBecomesTrackStartTimestamp
    @run: (test) ->
      t = MidiTrack.restore(
        '{"name":"Test Track","state":"Stopped","timeSignatureBeats":4,"timeSignatureBar":4,"start":1441599718706.365,"end":1441599719462.08,"duration":755.715087890625,"bpm":120,"canRecord":false,"options":{},"notes":{"1441599718705.92":{"value":60,"note":"C","octave":4,"velocity":46,"occurred":1441599718705.92,"duration":70.39501953125},"1441599718732.72":{"value":62,"note":"D","octave":4,"velocity":70,"occurred":1441599718732.72,"duration":135.10498046875},"1441599718825.27":{"value":64,"note":"E","octave":4,"velocity":55,"occurred":1441599718825.27,"duration":75.35498046875}},"noteEventMap":{"1441599718705.92":{"type":"Note On","value":60,"note":"C","octave":4,"velocity":46,"occurred":1441599718705.92},"1441599718732.72":{"type":"Note On","value":62,"note":"D","octave":4,"velocity":70,"occurred":1441599718732.72},"1441599718825.27":{"type":"Note On","value":64,"note":"E","octave":4,"velocity":55,"occurred":1441599718825.27}},"noteEventList":[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],"orderedTimestampList":[1441599718705.92,1441599718732.72,1441599718825.27]}')
      pt = new MidiTrackProcessor({firstNoteTimestampBecomesTrackStartTimestamp: true}).processTrack(t)
      firstNoteTimestamp = pt.orderedTimestampList[0]
      trackStartTimestamp = pt.start
      if firstNoteTimestamp != trackStartTimestamp
        test.errors.push "FirstNoteTimestampBecomesTrackStartTimestamp failed: The track's first note event `#{firstNoteTimestamp}` is not equal to `#{trackStartTimestamp}`"

  @run: (options = {}) ->
    MidiTests::FirstNoteTimestampBecomesTrackStartTimestamp.run(@)
    if @errors.length > 0
      console.log("WebMIDI: MidiTests test cases failed.")
      for error, index in @errors
        console.log("\t Error ##{index}: #{error}")
    else
      console.log("WebMIDI: All MidiTests test cases passed.")

@MidiTests.run()