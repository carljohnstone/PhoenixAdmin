/*
Copyright (c) 2003-2012, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
	config.toolbar_Phoenix =
	[
		['Bold', 'Italic', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink', '-', 'Blockquote', '-', 'Source']
	];
	config.toolbar = 'Phoenix';
	config.entities  = false;
	config.basicEntities = false;
//	config.entities_additional = 'lt,gt,amp,apos,quot'
	config.entities_latin = false;
	config.entities_greek = false;
	
	config.extraPlugins = 'autogrow';
	config.autoGrow_onStartup = true;
};

CKEDITOR.on('instanceReady', function( ev ) {
  var blockTags = ['div','h1','h2','h3','h4','h5','h6','p','pre','li','blockquote','ul','ol',
  'table','thead','tbody','tfoot','td','th',];

  for (var i = 0; i < blockTags.length; i++)
  {
     ev.editor.dataProcessor.writer.setRules( blockTags[i], {
        indent : false,
        breakBeforeOpen : true,
        breakAfterOpen : false,
        breakBeforeClose : false,
        breakAfterClose : true
     });
  }
});