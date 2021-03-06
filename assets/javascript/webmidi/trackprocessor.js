// Generated by CoffeeScript 1.10.0
(function() {
  this.MidiTrackProcessor = (function() {
    function MidiTrackProcessor(options) {
      if (options == null) {
        options = {};
      }
      this.options = options;
    }

    MidiTrackProcessor.prototype.processTrack = function(originalTrack) {
      var firstEventTimestamp, i, index, len, originalNote, originalTimestamp, ref, timestampDelta, track, trackStartTimestamp;
      track = JSON.parse(JSON.stringify(originalTrack));
      if (this.options.firstNoteTimestampBecomesTrackStartTimestamp) {
        firstEventTimestamp = track.orderedTimestampList[0];
        trackStartTimestamp = track.start;
        timestampDelta = firstEventTimestamp - trackStartTimestamp;
        ref = track.orderedTimestampList;
        for (index = i = 0, len = ref.length; i < len; index = ++i) {
          originalTimestamp = ref[index];
          originalNote = track.notes[originalTimestamp];
          originalNote.occurred -= timestampDelta;
          originalNote.duration -= timestampDelta;
          delete track.notes[originalTimestamp];
          track.notes[originalTimestamp - timestampDelta] = originalNote;
          track.orderedTimestampList[index] -= timestampDelta;
        }
      }
      if (this.options.quantize) {
        this.quantizeLengths();
      }
      this.calculateNoteDurations(track);
      return track;
    };

    MidiTrackProcessor.prototype.calculateNoteDurations = function(track) {
      var beatLength, beatType, i, index, len, noteEvent, noteType, ref, results, timestamp;
      beatLength = 60 / track.bpm;
      beatType = 4;
      ref = track.orderedTimestampList;
      results = [];
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        timestamp = ref[index];
        noteEvent = track.notes[timestamp];
        noteType = beatType * beatLength / (noteEvent.duration / 1000);
        noteEvent.duration_notation = noteType;
        results.push(console.log(noteEvent.duration_notation));
      }
      return results;
    };

    MidiTrackProcessor.prototype.quantizeLengths = function(track) {
      var beatLength;
      return beatLength = 60 / this.options.bpm;
    };

    return MidiTrackProcessor;

  })();

}).call(this);

//# sourceMappingURL=trackprocessor.js.map
