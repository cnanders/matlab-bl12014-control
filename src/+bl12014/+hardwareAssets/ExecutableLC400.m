

classdef ExecutableLC400 < LC400
    methods
        function executePupilFillWriteSequence(this)
            this.sequenceWriteIllum.execute();
        end
        function abortPupilFillWriteSequence(this)
            this.sequenceWriteIllum.abort();
        end
    end
end