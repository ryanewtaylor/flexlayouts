package org.flexlayouts.layouts {
	import mx.controls.Alert;
	import mx.core.ILayoutElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;

	/**
	 * A custom flow layout based heavily on Evtim's FlowLayout:
	 * http://evtimmy.com/2009/06/flowlayout-a-spark-custom-layout-example/
	 */
	public class FlowLayout extends VerticalLayout {
		private var _padding:Number = 0;
		private var _horizontalGap:Number = 6;
		private var _verticalGap:Number = 6;

		public function set padding(val:Number):void {
			_padding = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateDisplayList();
			}
		}

		public function set horizontalGap(val:Number):void {
			_horizontalGap = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateDisplayList();
			}
		}

		public function set verticalGap(val:Number):void {
			_verticalGap = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) {
				layoutTarget.invalidateDisplayList();
			}
		}
		
		override public function measure():void {
			
			var layoutTarget:GroupBase = target;
			var numElements:Number = layoutTarget.numElements;
			var previousYCoord:Number = 0;
			var numRows:Number = 1;
			var maxElementHeight:Number = 0;
			
			for (var i:int = 0; i < numElements; i++)
			{
				var element:ILayoutElement = ( useVirtualLayout ? layoutTarget.getVirtualElementAt(i) : layoutTarget.getElementAt(i) );
				if (!element.includeInLayout) continue;
				
				var currentYCoord:Number = element.getLayoutBoundsY();
				
				var currElementHeight:Number = element.getLayoutBoundsHeight();
				if (maxElementHeight < currElementHeight) maxElementHeight = currElementHeight;
				
				// When the current Y coordinate is different from the previous coordinate 
				// the element is in a new row
				if (currentYCoord != previousYCoord)
				{
					numRows++;
					previousYCoord = currentYCoord;
				}
			}
			
			var numVerticalGaps:Number = numRows - 1;
			var totalVerticalGapWidth:Number = numVerticalGaps * _verticalGap;
			layoutTarget.measuredHeight = numRows * maxElementHeight + totalVerticalGapWidth; 
		}

		override public function updateDisplayList(containerWidth:Number, containerHeight:Number):void {
			var x:Number = _padding;
			var y:Number = _padding;
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			var rowMaxHeight:Number = 0;

			//loop through all the elements
			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;

			for (var i:int = 0; i < count; i++) {
				var element:ILayoutElement = ( useVirtualLayout ? layoutTarget.getVirtualElementAt(i) : layoutTarget.getElementAt(i) );
				if (!element.includeInLayout) continue;
					
				//resize the element to its preferred size by passing in NaN
				element.setLayoutBoundsSize(NaN, NaN);

				//get element's size, but AFTER it has been resized to its preferred size.
				var elementWidth:Number = element.getLayoutBoundsWidth();
				var elementHeight:Number = element.getLayoutBoundsHeight();

				//does the element fit on this line (including padding), or should we move to the next line?
				if (x + elementWidth + _padding > containerWidth) {
					//start from the left side
					x = _padding;

					//move to the next line, and add the gap, but not if it's the first element
					if (i > 0) {
						y += rowMaxHeight + _verticalGap;

						//new row, so reset max height of this row
						rowMaxHeight = 0;
					}
				}
				//position the element
				element.setLayoutBoundsPosition(x, y);

				//update max dimensions (needed for scrolling)
				maxWidth = Math.max(maxWidth, x + elementWidth);
				maxHeight = Math.max(maxHeight, y + elementHeight);

				//update the current pos, and add the gap
				x += elementWidth + _horizontalGap;

				//update the max height of current row as necessary
				if (elementHeight > rowMaxHeight) {
					rowMaxHeight = elementHeight;
				}
			}

			//set final content size (needed for scrolling)
			layoutTarget.setContentSize(maxWidth + _padding, maxHeight + _padding);
			layoutTarget.invalidateSize();
		}
	}
}