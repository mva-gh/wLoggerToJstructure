( function _ToJs_test_s_( ) {

'use strict'; /*aaa*/

if( typeof module !== 'undefined' )
{

  try
  {
    require( '../printer/top/ToJs.s' );
  }
  catch( err )
  {
    require( '../oclass/printer/top/ToJs.s' );
  }

  var _ = wTools;

  _.include( 'wTesting' );


}

var _ = wTools;
var Parent = wTools.Testing;
var Self = {};

//

var toJsStructure = function( test )
{
  test.description = 'case1';
  var loggerToJstructure  = new wPrinterToJs();
  loggerToJstructure.log( '123' );
  var got = loggerToJstructure.outputData;
  var expected = [ '123' ];
  test.identical( got, expected );

  test.description = 'case2';
  var loggerToJstructure  = new wPrinterToJs();
  loggerToJstructure.up( 2 );
  loggerToJstructure.log( '123' );
  var got = loggerToJstructure.outputData;
  var expected =
  [
    [
      [ '123' ]
    ]
  ];
  test.identical( got, expected );

  test.description = 'case3';
  var loggerToJstructure  = new wPrinterToJs();
  loggerToJstructure.log();
  var got = loggerToJstructure.outputData;
  var expected = [ '' ];
  test.identical( got, expected );

  test.description = 'case4';
  var loggerToJstructure  = new wPrinterToJs();
  loggerToJstructure.log( '321');
  var got = loggerToJstructure.toJson();
  var expected = '[ "321" ]';
  test.identical( got, expected );

}

//

var chaining = function( test )
{
  var consoleWasBarred = false;

  var removeBar = () =>
  {
    if( _.Logger.consoleIsBarred( console ) )
    {
      consoleWasBarred = true;
      debugger
      _global_.wTester._bar.bar = 0;
      _.Logger.consoleBar( _global_.wTester._bar );
    }
  };

  var restoreBar = () =>
  {
    _global_.wTester._bar = _.Logger.consoleBar({ outputLogger : _global_.wTester.logger, bar : 1 });
    test.shouldBe( _.Logger.consoleIsBarred( console ) );
  };

  test.description = 'case1';
  var loggerToJstructure = new wPrinterToJs();
  var l = new _.Logger();
  l.outputTo( loggerToJstructure, { combining : 'rewrite' } );
  l.log( 'msg' );
  var got = loggerToJstructure.outputData;
  var expected = [ 'msg' ];
  test.identical( got, expected );

  test.description = 'case2';
  var loggerToJstructure = new wPrinterToJs();
  var l = new _.Logger();
  l.outputTo( loggerToJstructure, { combining : 'rewrite' } );
  l.up( 2 );
  l.log( 'msg' );
  var got = loggerToJstructure.outputData;
  var expected = [ '    msg' ];
  test.identical( got, expected );

  test.description = 'case3';
  var loggerToJstructure = new wPrinterToJs();
  var l = new _.Logger();
  l.outputTo( loggerToJstructure, { combining : 'rewrite' } );
  loggerToJstructure.up( 2 );
  l.log( 'msg' );
  var got = loggerToJstructure.outputData;
  var expected =
  [
    [
      [ 'msg' ]
    ]
  ];
  test.identical( got, expected );

  // test.description = 'case4: Logger->LoggerToJs, leveling on';
  // var loggerToJstructure = new wPrinterToJs();
  // var l = new _.Logger();
  // l.outputTo( loggerToJstructure, { combining : 'rewrite', leveling : 'delta' } );
  // l.log( 'msg' );
  // l.up( 2 );
  // l.log( 'msg2' );
  // var got = loggerToJstructure.outputData;
  // var expected =
  // [
  //   [
  //      [ '    msg2' ],
  //   ],
  //   'msg'
  // ];
  // test.identical( got, expected );

  test.description = 'case5 LoggerToJs->LoggerToJs';
  var loggerToJstructure = new wPrinterToJs();
  var loggerToJstructure2 = new wPrinterToJs();
  loggerToJstructure.outputTo( loggerToJstructure2, { combining : 'rewrite' } );
  loggerToJstructure.log( '1' );
  loggerToJstructure2.log( '2' );
  var got =
  [
    loggerToJstructure.outputData,
    loggerToJstructure2.outputData
  ];

  var expected =
  [
    [ '1' ],
    [ '1', '2' ]
  ];
  test.identical( got, expected );

  test.description = 'case6: LoggerToJs->Logger->LoggerToJs';
  var loggerToJstructure = new wPrinterToJs();
  var loggerToJstructure2 = new wPrinterToJs();
  var l = new _.Logger();
  loggerToJstructure.outputTo( l, { combining : 'rewrite' } );
  l.outputTo( loggerToJstructure2, { combining : 'rewrite' } );
  l._prefix = '*';
  debugger
  loggerToJstructure.log( '1' );
  var got =
  [
    loggerToJstructure.outputData,
    loggerToJstructure2.outputData
  ];

  var expected =
  [
    [ '1' ],
    [ '*1' ]
  ];
  test.identical( got, expected );

  test.description = 'case7: input from console';
  var loggerToJstructure = new wPrinterToJs();
  removeBar();
  loggerToJstructure.inputFrom( console );
  console.log( 'abc' );
  loggerToJstructure.inputUnchain( console );
  restoreBar();
  var got = loggerToJstructure.outputData;
  var expected =
  [
    'abc'
  ];
  test.identical( got, expected );

  test.description = 'case8: input from console twice';
  var loggerToJstructure1 = new wPrinterToJs();
  var loggerToJstructure2 = new wPrinterToJs();
  removeBar();
  loggerToJstructure1.inputFrom( console );
  loggerToJstructure2.inputFrom( console );
  console.log( 'abc' )
  loggerToJstructure1.inputUnchain( console )
  loggerToJstructure2.inputUnchain( console )
  restoreBar();

  var got =
  [
    loggerToJstructure1.outputData,
    loggerToJstructure2.outputData
  ];

  var expected =
  [
    [ 'abc' ],
    [ 'abc' ]
  ];
  test.identical( got, expected );

}

//


function leveling( test )
{
  var loggerToJstructure = new wPrinterToJs();
  loggerToJstructure.level = 5;
  test.identical( loggerToJstructure.level, 5 );
  loggerToJstructure.log( 1 );
  var got = loggerToJstructure.outputData;
  var expected =
  [
    [
      [
        [
          [
            [ '1' ]
          ]
        ]
      ]
    ]
  ]
  test.identical( got,expected )
  loggerToJstructure.level = 0;
  loggerToJstructure.log( 1 );
  expected.push( '1' );
  test.identical( got,expected )
  test.identical( loggerToJstructure.level, 0 );

  /**/

  var loggerToJstructure = new wPrinterToJs();
  loggerToJstructure.up( 5 );
  test.identical( loggerToJstructure.level, 5 );
  loggerToJstructure.log( 1 );
  var got = loggerToJstructure.outputData;
  var expected =
  [
    [
      [
        [
          [
            [ '1' ]
          ]
        ]
      ]
    ]
  ]
  test.identical( got,expected )
  loggerToJstructure.down( 5 );
  loggerToJstructure.log( 1 );
  expected.push( '1' );
  test.identical( got,expected );
  test.identical( loggerToJstructure.level, 0 );

  /**/

  var loggerToJstructure = new wPrinterToJs();
  loggerToJstructure._prefix = '*';
  loggerToJstructure.level = 2;
  loggerToJstructure.log( 1 );
  var got = loggerToJstructure.outputData;
  var expected = [ [ [ '*1' ] ] ];
  test.identical( got, expected )
}

//

var Proto =
{

  name : 'LoggerToJs test',
  silencing : 1,

  tests :
  {

   toJsStructure : toJsStructure,
   chaining : chaining,
   leveling  : leveling

  },

}

//

_.mapExtend( Self,Proto );
Self = wTestSuit( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
