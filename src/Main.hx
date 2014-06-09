package;
import haxe.crypto.Md5;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.Resource;
import format.abc.Data;
import sys.io.File;
 
using Main;

class Main {
    
    static function main() {
        new Main();
    }
    
    public function new() {
		  
		// var swfInput = new BytesInput( Resource.getBytes( "C:\\openfl\\swf-obfuscator2\\bin\\game.swf" ) );
		trace(Resource.getBytes( "game" ));
		//return;
       var swfInput =  File.read("source.swf");// new BytesInput( Resource.getBytes( "game" ) );
		 trace("swfInput", swfInput);
		//  return ;
		 
        var swfReader = new format.swf.Reader( swfInput );
        var swf  = swfReader.read();
        
        for( i in 0...swf.tags.length ) {
            var tag = swf.tags[i];
			//trace("tag=", tag);
            switch( tag ) {
                case TSymbolClass( classes ):
                     //trace( ' = Class linkage: $classes' );
                    
                case TActionScript3( abcBytes, other ):
					//trace("context ===========....", (other ==null)?"": "#"+other.id+","+other.label+"'");
                    swf.tags[i] = TActionScript3( transformAbc( abcBytes ) );
                    
                case _:
            }
        }
        
        var swfOutput = new BytesOutput();
        var swfWriter = new format.swf.Writer( swfOutput );
        swfWriter.write( swf ); 
	 
	  sys.io.File.saveBytes("target.swf", swfOutput.getBytes());
        
        // swfOutput.getBytes() now returns the modified SWF, which you can write to disk.
    }
    
    function transformAbc( abcBytes : Bytes )
    {
        var abcInput = new BytesInput( abcBytes );
        var abcReader = new format.abc.Reader( abcInput );
        
        var abcData = abcReader.read();
		 var reg1:EReg = ~/([a-zA-Z0-9])+ControllerXXXX$/;
		  var reg2:EReg = ~/([a-zA-Z0-9])+View$/;
		  var id:Int  = 128 ;

        for( cls in abcData.classes ) {
           // trace("cls.name = " , cls.name);
			// trace("cls.name2 = " , abcData.getName( cls.name ));
            switch( abcData.getName( cls.name ) ) {
                case NName( name, ns ):
                    var nameString = abcData.getString( name );	
                   // var newNameString = '${nameString}_Modified';
				   
					 if ( (reg1.match(nameString) || reg2.match(nameString) ) ) {
						 if (nameString != "SocketView" && nameString != "IView") { 
							 ++id;
							 
					 var newNameString = Md5.encode("\x148"+id+"");// "\x148" + Std.string(10 + id) + "";// 'JET${nameString}';
					 
                    abcData.setString( name, newNameString);
						 trace( '== ================Class: $nameString changed to $newNameString' ); }}
                case _:
                    throw "Unexpected class name";
            }
            
        }
        var f :format.abc.Function ;
        for ( f  in abcData.functions ) {
			//trace("function" , abcData.getName( f.code ));
		  //trace("function  = ", f.code );
		//  var ops = format.abc.OpReader.decode(new haxe.io.BytesInput(f.code));
		  
		 // trace("OPS");
             //  var code = format.abc.OpReader.decode( new BytesInput( f.code ) );
             //  trace( code );
        }
		
		 for ( f1 in abcData.strings ) {
			// trace("f1  = ", f1 );
             // var code = format.abc.OpReader.decode( new BytesInput( f.code ) );
             //  trace( code );
        }
		
		
		for ( f3 in abcData.methodTypes ) {
			// trace("f3  = ", f3.args ,f3.ret ,f3.extra );
             // var code = format.abc.OpReader.decode( new BytesInput( f.code ) );
             //  trace( code );
        }

        var abcOutput = new BytesOutput();
        var abcWriter = new format.abc.Writer( abcOutput );
        abcWriter.write( abcData );
        
        return abcOutput.getBytes();
    }
    
    // Static extensions for easier dereferencing of indices
    public static function getName( abcData : format.abc.Data.ABCData, idx : Index<Name> ) : Name {
		//trace("dddd", idx);
		//trace("dddd= " , Idx(i));
        switch( idx ) {
            case Idx(i):    return abcData.names[i-1];
        }
    }
    
    public static function getString( abcData : format.abc.Data.ABCData, idx : Index<String> ) : String {
		//trace("HERER!!!" ,idx );
        switch( idx ) {
            case Idx(i):    return abcData.strings[i-1];
        }
    }
    
    public static function setString( abcData : format.abc.Data.ABCData, idx : Index<String>, value : String ) {
        switch( idx ) {
            case Idx(i):    abcData.strings[i-1] = value;
        }
    }
}