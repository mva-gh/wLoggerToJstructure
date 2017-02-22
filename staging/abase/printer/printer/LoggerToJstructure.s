(function _LoggerToJstructure_s_() {

'use strict';

// require

if( typeof module !== 'undefined' )
{

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  _.include( 'wLogger' );

}

var symbolForLevel = Symbol.for( 'level' );

//

/**
 *
 *
 * @classdesc Logger based on [wLogger]{@link wLogger} that writes messages( incoming & outgoing ) to own data structure( array of arrays ).
 *
 * Each inner array represent new level of the structure. On write logger puts messages into structure level which is equal to logger level property value.<br>
 * If needed level not exists logger creates it. Next level is always placed at zero index of previous.<br>
 * <br><b>Methods:</b><br><br>
 * Output:
 * <ul>
 * <li>log
 * <li>error
 * <li>info
 * <li>warn
 * </ul>
 * Leveling:
 * <ul>
 *  <li>Increase current level [up]{@link wPrinterMid.up}
 *  <li>Decrease current level [down]{@link wPrinterMid.down}
 * </ul>
 * Chaining:
 * <ul>
 *  <li>Add object to output list [outputTo]{@link wPrinterMid.outputTo}
 *  <li>Remove object from output list [outputToUnchain]{@link wPrinterMid.outputToUnchain}
 *  <li>Add current logger to target's output list [inputFrom]{@link wPrinterMid.inputFrom}
 *  <li>Remove current logger from target's output list [inputFromUnchain]{@link wPrinterMid.inputFromUnchain}
 * </ul>
 * Other:
 * <ul>
 * <li>Convert data structure to json string [toJson]{@link wLoggerToJstructure.toJson}
 * </ul>
 * @class wLoggerToJstructure
 * @param { Object } o - Options.
 * @param { Object } [ o.output=null ] - Specifies single output object for current logger.
 * @param { Object } [ o.outputData=[ ] ] - Specifies where to write messages.
 *
 * @example
 * var l = new wLoggerToJstructure();
 * l.log( '1' );
 * l.outputData; //returns [ '1' ]
 *
 * @example
 * var data = [];
 * var l = new wLoggerToJstructure({ outputData : data });
 * l.log( '1' );
 * console.log( data ); //returns [ '1' ]
 *
 * @example
 * var l = new wLoggerToJstructure({ output : console });
 * l.log( '1' ); // console prints '1'
 * l.outputData; //returns [ '1' ]
 *

 */

var _ = wTools;
var Parent = wPrinterTop;
var Self = function wLoggerToJstructure( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

function init( o )
{
  var self = this;

  Parent.prototype.init.call( self,o );

  self._currentContainer = self.outputData;

}

//

// function __initChainingMixinWrite( name )
// {
//   var proto = this;
//
//   _.assert( Object.hasOwnProperty.call( proto,'constructor' ) )
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( name ) );
//
//   var nameAct = name + 'Act';
//
//   /* */
//
//   function write()
//   {
//     this._writeToStruct.apply( this, arguments );
//     if( this.output )
//     return this[ nameAct ].apply( this,arguments );
//   }
//
//   proto[ name ] = write;
// }

//

// function _writeToStruct()
// {
//   if( !arguments.length )
//   return;
//
//   var data = _.strConcat.apply( {}, arguments );
//
//   this._currentContainer.push( data );
// }

//

function write()
{
  var self = this;

  // if( !arguments.length )
  // return;

  var args = self._writeBegin( arguments );

  _.assert( _.arrayIs( args ) );
  _.assert( args.length === 1 );

  if( self.onWrite )
  self.onWrite( args[ 0 ] );

  // var data = _.strConcat.apply( {}, arguments );

  var terminal = args[ 0 ];
  if( self.usingTags && _.mapKeys( self.tags ).length )
  {

    var text = terminal;
    terminal = Object.create( null );
    terminal.text = text;

    for( var t in self.tags )
    {
      terminal[ t ] = self.tags[ t ];
    }

  }

  this._currentContainer.push( terminal );
}

//

function levelSet( level )
{
  var self = this;

  _.assert( level >= 0, 'levelSet : cant go below zero level to',level );
  _.assert( isFinite( level ) );

  // function _changeLevel( arr, level )
  // {
  //   if( !level )
  //   return arr;
  //
  //   if( !arr[ 0 ] )
  //   arr[ 0 ] = [ ];
  //   else if( !_.arrayIs( arr[ 0 ] ) )
  //   arr.unshift( [] );
  //
  //   return _changeLevel( arr[ 0 ], --level );
  // }

  var dLevel = level - self[ symbolForLevel ];

  Parent.prototype.levelSet.call( self,level );

  if( dLevel > 0 )
  {
    for( var l = 0 ; l < dLevel ; l++ )
    {
      var newContainer = [];
      self._currentContainers.push( self._currentContainer );
      self._currentContainer.push( newContainer );
      self._currentContainer = newContainer;
    }
  }
  else if( dLevel < 0 )
  {
    _.assert( _.arrayLike( self._currentContainers[ -dLevel-1 ] ) || _.objectLike( self._currentContainers[ -dLevel-1 ] ) );
    self._currentContainer = self._currentContainers[ -dLevel-1 ];
    self._currentContainers.splice( 0,-dLevel );
    if( level === 0 )
    _.assert( self._currentContainers.length === 0 );
  }

}

//

/**
 * Converts logger data structure to JSON string.
 * @returns Data structure as JSON string.
 *
 * @example
 * var l = new wLoggerToJstructure();
 * l.up( 2 );
 * l.log( '1' );
 * l.toJson();
 * //returns
 * //[
 * // [
 * //  [ '1' ]
 * // ]
 * //]
 * @method toJson
 * @memberof wLoggerToJstructure
 */

function toJson()
{
  var self = this;
  return _.toStr( self.outputData, { json : 1 } );
}

// --
// relationships
// --

var Composes =
{
  usingTags : 1,
}

var Aggregates =
{
  outputData : [],
}

var Associates =
{
}

var Restricts =
{
  _currentContainer : null,
  _currentContainers : [],
}

// --
// prototype
// --

var Proto =
{

  init : init,

  // __initChainingMixinWrite : __initChainingMixinWrite,
  // _writeToStruct : _writeToStruct,

  write : write,

  levelSet : levelSet,

  toJson : toJson,

  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

// Self.prototype._initChainingMixin();

//

_.accessor
({
  object : Self.prototype,
  names :
  {
    level : 'level',
  },
  combining : 'rewrite'
});

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
{
  module[ 'exports' ] = Self;
}

_global_[ Self.name ] = wTools.LoggerToJstructure = Self;

return Self;

})();
