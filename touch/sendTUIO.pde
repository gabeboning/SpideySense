import com.illposed.osc.*;
import java.net.InetAddress;
import java.lang.*;

class sendTUIO {
  InetAddress address;
  OSCPortOut sender;

  sendTUIO() {
    try {
      address = InetAddress.getLocalHost();
      sender = new OSCPortOut(address, 3333);
    }
    catch (Exception e) {
      println("error initiating OSC");
    }
  }

  // send blob info over TUIO so applications can use it
  void broadcastBlobs(ArrayList<ABlob> blobs, int frame) {
    try {
      Object args[] = new Object[2];
      args[0] = "source";
      args[1] = "spideysence@spideysensehost";
      OSCMessage msg = new OSCMessage("/tuio/2Dcur", args);
      sender.send(msg);

      args = new Object[blobs.size() + 1];
      int i = 1;
      args[0] = "alive";

      for (ABlob b : blobs) {
        args[i++] = new Integer(b.id);
      }
      msg = new OSCMessage("/tuio/2Dcur", args);
      sender.send(msg);

      for (ABlob b : blobs) {
        args = new Object[7];
        args[0] = "set";
        args[1] = new Integer(b.id); // blob id
        args[2] = new Float(b.cx / width); // blob x position
        args[3] = new Float(b.cy / height); // blob y position 
        args[4] = new Float(b.headx); // x velocity
        args[5] = new Float(b.heady); // y velocity
        args[6] = new Float(3); // motion acceleration
        msg = new OSCMessage("/tuio/2Dcur", args);
        sender.send(msg);
      }
      args = new Object[2];
      args[0] = "fseq";
      args[1] = new Integer(frame);
      msg = new OSCMessage("/tuio/2Dcur", args);
      sender.send(msg);
    } 
    catch(Exception e) {
      println("error sending TUIO");
    }
  }
}

