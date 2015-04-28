from UM.Job import Job
from UM.Application import Application
from UM.Message import Message

import os.path

##  A Job subclass that performs mesh loading.
#
#   The result of this Job is a MeshData object.
class ReadMeshJob(Job):
    def __init__(self, filename):
        super().__init__(description = "Loading mesh {0}".format(os.path.basename(filename)), visible = True)
        self._filename = filename
        self._handler = Application.getInstance().getMeshFileHandler()
        self._device = Application.getInstance().getStorageDevice('LocalFileStorage')

    def getFileName(self):
        return self._filename

    def run(self):
        self.setResult(self._handler.read(self._filename, self._device))
        result_message = Message("Loaded %s" %self._filename)
        result_message.show()
        
