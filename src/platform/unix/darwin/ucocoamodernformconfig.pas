unit uCocoaModernFormConfig;

{$mode ObjFPC}{$H+}
{$modeswitch objectivec2}

interface

uses
  Classes, SysUtils,
  Forms,
  fMain, uFileView, uBriefFileView, uColumnsFileView, uThumbFileView,
  CocoaAll, CocoaConfig, CocoaToolBar, Cocoa_Extra, CocoaUtils;

implementation

procedure toggleTreeViewAction( const Sender: id );
begin
  frmMain.Commands.cm_TreeView([]);
end;

procedure toggleHorzSplitAction( const Sender: id );
begin
  frmMain.Commands.cm_HorizontalFilePanels([]);
end;

procedure showModeAction( const Sender: id );
var
  showModeItem: NSToolBarItemGroup absolute Sender;
begin
  case showModeItem.selectedIndex of
    0: frmMain.Commands.cm_BriefView([]);
    1: frmMain.Commands.cm_ColumnsView([]);
    2: frmMain.Commands.cm_ThumbnailsView([]);
  end;
end;

procedure onFileViewUpdated( const fileView: TFileView );
var
  itemGroup: NSToolbarItemGroup;
  itemGroupWrapper: TCocoaToolBarItemGroupWrapper;
begin
  itemGroup:= NSToolbarItemGroup( TCocoaToolBarUtils.findItemByIdentifier( frmMain, 'MainForm.ShowMode' ) );
  if NOT Assigned(itemGroup) then
    Exit;
  itemGroupWrapper:= TCocoaToolBarItemGroupWrapper( itemGroup.target );

  if fileView is TColumnsFileView then
    itemGroupWrapper.lclSetSelectedIndex( 1 )
  else if fileView is TBriefFileView then
    itemGroupWrapper.lclSetSelectedIndex( 0 )
  else if fileView is TThumbFileView then
    itemGroupWrapper.lclSetSelectedIndex( 2 );
end;

function onGetSharingItems( item: NSToolBarItem ): TStringArray;
begin
  Result:= frmMain.NSServiceMenuGetFilenames()
end;

procedure swapPanelsAction( const Sender: id );
begin
  frmMain.Commands.cm_Exchange([]);
end;

const
  treeViewItemConfig: TCocoaConfigToolBarItem = (
    identifier: 'MainForm.TreeView';
    priority: NSToolbarItemVisibilityPriorityStandard;
    navigational: True;
    iconName: 'sidebar.left';
    title: 'Tree View';
    tips: 'Tree View Panel';
    bordered: True;
    onAction: @toggleTreeViewAction;
  );

  horzSplitItemConfig: TCocoaConfigToolBarItem = (
    identifier: 'MainForm.HorzSplit';
    priority: NSToolbarItemVisibilityPriorityStandard;
    navigational: True;
    iconName: 'rectangle.split.1x2';
    title: 'HorzSplit';
    tips: 'Horizontal Panels Mode';
    bordered: True;
    onAction: @toggleHorzSplitAction;
  );


  showBriefItemConfig: TCocoaConfigToolBarItem = (
    identifier: 'MainForm.ShowMode.Brief';
    iconName: 'rectangle.split.3x1';
    title: 'Brief';
    tips: 'Brief Mode';
    bordered: True;
    onAction: nil;
  );

  showFullItemConfig: TCocoaConfigToolBarItem = (
    identifier: 'MainForm.ShowMode.Full';
    iconName: 'list.bullet';
    title: 'Full';
    tips: 'Full';
    bordered: True;
    onAction: nil;
  );

  showThumbnailsItemConfig: TCocoaConfigToolBarItem = (
    identifier: 'MainForm.ShowMode.Thumbnails';
    iconName: 'square.grid.2x2';
    title: 'Thumbnails';
    tips: 'Thumbnails';
    bordered: True;
    onAction: nil;
  );

  showModeItemConfig: TCocoaConfigToolBarItemGroup = (
    identifier: 'MainForm.ShowMode';
    priority: NSToolbarItemVisibilityPriorityHigh;
    iconName: '';
    title: 'ShowMode';
    tips: 'Show Mode';
    bordered: True;
    onAction: @showModeAction;

    representation: NSToolbarItemGroupControlRepresentationAutomatic;
    selectionMode: NSToolbarItemGroupSelectionModeSelectOne;
    selectedIndex: 0;
    subitems: (
    );
  );


  shareItemConfig: TCocoaConfigToolBarItemSharing = (
    identifier: 'MainForm.Share';
    priority: NSToolbarItemVisibilityPriorityUser;
    iconName: '';
    title: 'Share';
    tips: 'Share...';
    bordered: True;

    onGetItems: @onGetSharingItems;
  );

  swapPanelsItemConfig: TCocoaConfigToolBarItem = (
    identifier: 'MainForm.SwapPanels';
    priority: NSToolbarItemVisibilityPriorityStandard;
    navigational: False;
    iconName: 'arrow.left.arrow.right.square';
    title: 'Swap';
    tips: 'Swap Panels';
    bordered: True;
    onAction: @swapPanelsAction;
  );

  mainFormConfig: TCocoaConfigForm = (
    name: 'frmMain';
    className: '';
    isMainForm: False;

    titleBar: (
      transparent: False;
      separatorStyle: NSTitlebarSeparatorStyleAutomatic;
    );

    toolBar: (
      identifier: 'MainForm.ToolBar';
      style: NSWindowToolbarStyleAutomatic;
      displayMode: NSToolbarDisplayModeIconOnly;

      allowsUserCustomization: True;
      autosavesConfiguration: False;

      items: (
      );
      defaultItemsIdentifiers: (
        'MainForm.TreeView',
        'MainForm.HorzSplit',

        'MainForm.ShowMode',
        'NSToolbarFlexibleSpaceItem',
        'MainForm.Share',
        'MainForm.SwapPanels'
      );
      allowedItemsIdentifiers: (
        'MainForm.TreeView',
        'MainForm.HorzSplit',

        'MainForm.ShowMode',
        'MainForm.Share',
        'MainForm.SwapPanels'
      );
      itemCreator: nil;      // default item Creator
    );
  );

procedure initCocoaModernFormConfig;
begin
  showModeItemConfig.subitems:= [
    TCocoaToolBarUtils.toClass(showBriefItemConfig),
    TCocoaToolBarUtils.toClass(showFullItemConfig),
    TCocoaToolBarUtils.toClass(showThumbnailsItemConfig)
  ];

  mainFormConfig.toolBar.items:= [
    TCocoaToolBarUtils.toClass(treeViewItemConfig),
    TCocoaToolBarUtils.toClass(horzSplitItemConfig),

    TCocoaToolBarUtils.toClass(showModeItemConfig),
    TCocoaToolBarUtils.toClass(shareItemConfig),
    TCocoaToolBarUtils.toClass(swapPanelsItemConfig)
  ];

  CocoaConfigForms:= [ mainFormConfig ];

  fMain.onFileViewUpdated:= @onFileViewUpdated;
end;

initialization
  if NSAppKitVersionNumber >= NSAppKitVersionNumber11_0 then
    initCocoaModernFormConfig;

end.

