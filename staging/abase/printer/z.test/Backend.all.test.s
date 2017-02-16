( function _Backend_all_test_s_( ) {

'use strict';

/*

to run this test
from the project directory run

npm install
node ./staging/abase/z.test/All.backend.test.s

*/

if( typeof module !== 'undefined' )
{

  require( '../printer/LoggerToJstructure.s' );

  var _ = wTools;

  _.include( 'wTesting' );

  require( './LoggerToJstructure.test.s' );

}

var _ = wTools;

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test();

} )( );
