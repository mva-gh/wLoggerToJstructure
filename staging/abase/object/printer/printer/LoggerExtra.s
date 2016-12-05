(function _Logger_s_() {

'use strict';

// require

if( typeof module !== 'undefined' )
{

  if( typeof wPrinterMid === 'undefined' )
  require( '../PrinterMid.s' )

}

//


var _ = wTools;
var Parent = wPrinterMid;
var Self = wLogger;

//

var _wrapProtoHandler = function( methodName, originalMethod, proto )
{

  debugger;
  return function()
  {
    debugger;
    logger.logUp( proto.constructor.name + '.' + methodName,'(','with',arguments.length,'arguments',')' );
    var result = originalMethod.apply( this,arguments );
    logger.logDown();
    return result;
  }

}

//

var wrapProto = function( proto,o )
{
  var self = this;
  var o = o || {};

  _.assert( _.objectIs( proto ) || _.routineIs( proto ) );

  if( proto.constructor.wrappedByLogger )
  return;

  proto.constructor.wrappedByLogger = true;

  console.log( 'wrapProto :',proto.constructor.name );

  var methods = o.methods || proto;
  for( var r in methods )
  {

    if( r === 'constructor' )
    continue;

    var descriptor = Object.getOwnPropertyDescriptor( proto,r );

    if( !descriptor )
    continue;

    if( !descriptor.configurable )
    continue;

    var routine = proto[ r ];

    if( !_.routineIs( routine ) )
    continue;

    proto[ r ] = _wrapProtoHandler( r,routine,proto );
    proto[ r ].original = routine;

  }

}

//

var unwrapProto = function( proto )
{
  var self = this;
  var o = o || {};

  _.assert( _.objectIs( proto ) || _.routineIs( proto ) );

  if( !proto.constructor.wrappedByLogger )
  return;

  proto.constructor.wrappedByLogger = false;

  console.log( 'unwrapProto :',proto.constructor.name );

  var methods = o.methods || proto;
  for( var r in methods )
  {

    if( r === 'constructor' )
    continue;

    var descriptor = Object.getOwnPropertyDescriptor( proto,r );

    if( !descriptor )
    continue;

    if( !descriptor.configurable )
    {
      continue;
    }

    var routine = proto[ r ];

    if( !_.routineIs( routine ) )
    continue;

    if( !_.routineIs( routine.original ) )
    continue;

    proto[ r ] = routine.original;

  }

}

//

var _hookConsoleToFileHandler = function( wasMethod, methodName, fileName )
{

  return function ()
  {

    var args = arguments;
    //var args = _.arrayAppendMerging( [],arguments,_.stack() );

    wasMethod.apply( console,args );

    var fileProvider = _.FileProvider.def();
    if( fileProvider.fileWrite )
    {

      var strOptions = { levels : 7 };
      fileProvider.fileWrite
      ({
        path : fileName,
        data : _.toStr( args,strOptions ) + '\n',
        append : true,
      });

    }

  };

}

//

var hookConsoleToFile = function( fileName )
{
  var self = this;

  require( 'include/abase/component/Path.s' );
  require( 'include/Files.ss' );

  fileName = fileName || 'log.txt';
  fileName = _.pathJoin( _.pathMainDir(),fileName );

  console.log( 'hookConsoleToFile :',fileName );

  for( var i = 0, l = self._methods.length; i < l; i++ )
  {
    var m = self._methods[ i ];
    if( m in console )
    {
      var wasMethod = console[ m ];
      console[ m ] = self._hookConsoleToFileHandler( wasMethod,m,fileName );
    }
  }

}

//

var _hookConsoleToAlertHandler = function( wasMethod, methodName )
{

  return function ()
  {

    var args = _.arrayAppendMerging( [],arguments,_.stack() );

    wasMethod.apply( console,args );
    alert( args.join( '\n' ) );

  }

}

//

var hookConsoleToAlert = function()
{
  var self = this;

  console.log( 'hookConsoleToAlert' );

  for( var i = 0, l = self._methods.length; i < l; i++ )
  {
    var m = self._methods[ i ];
    if( m in console )
    {
      var wasMethod = console[ m ];
      console[ m ] = self._hookConsoleToAlertHandler( wasMethod,m );
    }
  }

}

//

var _hookConsoleToDomHandler = function( o, wasMethod, methodName )
{

  return function()
  {

    /*var args = _.arrayAppendMerging( [],arguments,_.stack() );*/
    wasMethod.apply( console,arguments );
    var text = [].join.call( arguments,' ' );
    o.consoleDom.prepend( '<p>' + text + '</p>' );

  }

}

//

var hookConsoleToDom = function( o )
{
  var self = this;
  var o = o || {};
  var $ = jQuery;

  $( document ).ready( function( )
  {

    if( !o.dom )
    o.dom = $( document.body );

    var consoleDom = o.consoleDom = $( '<div>' ).appendTo( o.dom );
    consoleDom.css
    ({
      'display' : 'block',
      'position' : 'absolute',
      'bottom' : '0',
      'width' : '100%',
      'height' : '50%',
      'z-index' : '10000',
      'background-color' : 'rgba( 255,0,0,0.1 )',
      'overflow-x' : 'hidden',
      'overflow-y' : 'auto',
      'padding' : '1em',
    });

    console.log( 'hookConsoleToDom' );

    for( var i = 0, l = self._methods.length; i < l; i++ )
    {
      var m = self._methods[ i ];
      if( m in console )
      {
        var wasMethod = console[ m ];
        console[ m ] = self._hookConsoleToDomHandler( o,wasMethod,m );
      }
    }

  });

}

//

var _hookConsoleToServerSend = function( o, data )
{
  var self = this;

  var request = $.ajax
  ({
    url : o.url,
    crossDomain : true,
    method : 'post',
    /*dataType : 'json',*/
    data : JSON.stringify( data ),
    error : _.routineJoin_( self,self.unhookConsole,[ false ] ),
  });

}

//

var _hookConsoleToServerHandler = function( o, originalMethod, methodName )
{
  var self = this;

  return function()
  {

    originalMethod.apply( console,arguments );
    var text = [].join.call( arguments,' ' );
    var data = {};
    data.text = text;
    data.way = 'message';
    data.method = methodName;
    data.o = o;

    self._hookConsoleToServerSend( o,data );

  }

}

//

var hookConsoleToServer = function( o )
{
  var self = this;

  if( console._hook )
  return;

  console._hook = 'hookConsoleToServer';

  // var

  var $ = jQuery;
  var o = o || {};
  var optionsDefault =
  {
    url : null,
    id : null,
    pathname : '/log',
  }

  throw _.err( 'not tested' );

  _.assertMapHasOnly( o,optionsDefault,_.urlMake.components,undefined );
  _.mapSupplement( o,optionsDefault );

  if( !o.url )
  o.url = _.urlFor( o );

  if( !o.id )
  o.id = _.numberRandomInt( 1 << 30 );

  console.log( 'hookConsoleToServer :',o.url );

  //

  for( var i = 0, l = self._methods.length; i < l; i++ )
  {
    var m = self._methods[ i ];
    if( m in console )
    {
      var originalMethod = console[ m ];
      console[ m ] = self._hookConsoleToServerHandler( o,originalMethod,m );
      console[ m ].original = originalMethod;
    }
  }

  // handshake

  var data = {};
  data.way = 'handshake';
  data.o = o;

  self._hookConsoleToServerSend( o,data );

}

//

var unhookConsole = function( force )
{
  var self = this;

  if( !console._hook && !force )
  return;

  console._hook = false;
  console.log( 'unhookConsole :' );

  for( var i = 0, l = self._methods.length; i < l; i++ )
  {
    var m = self._methods[ i ];
    if( m in console )
    {
      _.assert( _.routineIs( console[ m ].original ) );
      console[ m ] = console[ m ].original;
    }
  }

}

//

var _methods =
[
  'log', 'assert', 'clear', 'count',
  'debug', 'dir', 'dirxml', 'error',
  'exception', 'group', 'groupCollapsed',
  'groupEnd', 'info', 'profile', 'profileEnd',
  'table', 'time', 'timeEnd', 'timeStamp',
  'trace', 'warn'
];

// --
// relationships
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
}

// --
// prototype
// --

var Proto =
{

  _wrapProtoHandler : _wrapProtoHandler,
  wrapProto : wrapProto,
  unwrapProto : unwrapProto,

  _hookConsoleToFileHandler : _hookConsoleToFileHandler,
  hookConsoleToFile : hookConsoleToFile,

  _hookConsoleToAlertHandler : _hookConsoleToAlertHandler,
  hookConsoleToAlert : hookConsoleToAlert,

  _hookConsoleToDomHandler : _hookConsoleToDomHandler,
  hookConsoleToDom : hookConsoleToDom,

  _hookConsoleToServerSend : _hookConsoleToServerSend,
  _hookConsoleToServerHandler : _hookConsoleToServerHandler,
  hookConsoleToServer : hookConsoleToServer,

  unhookConsole : unhookConsole,

  // var

  _methods : _methods,

  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,

}

//

//debugger;
_.protoExtend( Self,Proto );

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
{
  module[ 'exports' ] = Self;
}

return Self;

})();
