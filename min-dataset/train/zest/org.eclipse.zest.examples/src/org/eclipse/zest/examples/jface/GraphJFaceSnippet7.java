/*******************************************************************************
 * Copyright 2005-2007, CHISEL Group, University of Victoria, Victoria, BC,
 * Canada. All rights reserved. This program and the accompanying materials are
 * made available under the terms of the Eclipse Public License v1.0 which
 * accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: The Chisel Group, University of Victoria
 ******************************************************************************/
package org.eclipse.zest.examples.jface;

import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.Label;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.zest.core.viewers.EntityConnectionData;
import org.eclipse.zest.core.viewers.GraphViewer;
import org.eclipse.zest.core.viewers.IFigureProvider;
import org.eclipse.zest.core.viewers.IGraphEntityContentProvider;
import org.eclipse.zest.core.viewers.INestedContentProvider;
import org.eclipse.zest.examples.uml.UMLClassFigure;
import org.eclipse.zest.layouts.algorithms.SpringLayoutAlgorithm;

/**
 * This snippet shows how to use the INestedGraphContentProvider to create a
 * graph with Zest. In this example, getElements returns 3 edges: * Rock2Paper *
 * Paper2Scissors * Scissors2Rock
 * 
 * And for each of these, the source and destination are returned in getSource
 * and getDestination.
 * 
 * A label provider is also used to create the text and icons for the graph.
 * 
 * @author Ian Bull
 * 
 */
public class GraphJFaceSnippet7 {

	public static IFigure createClassFigure1(Font classFont, Image classImage,
			Image publicField, Image privateField) {
		Label classLabel1 = new Label("Table", classImage);
		classLabel1.setFont(classFont);

		UMLClassFigure classFigure = new UMLClassFigure(classLabel1);
		Label attribute1 = new Label("columns: Column[]", privateField);

		Label attribute2 = new Label("rows: Row[]", privateField);

		Label method1 = new Label("getColumns(): Column[]", publicField);
		Label method2 = new Label("getRows(): Row[]", publicField);
		classFigure.getAttributesCompartment().add(attribute1);
		classFigure.getAttributesCompartment().add(attribute2);
		classFigure.getMethodsCompartment().add(method1);
		classFigure.getMethodsCompartment().add(method2);
		classFigure.setSize(-1, -1);

		return classFigure;
	}

	static class MyContentProvider implements IGraphEntityContentProvider,
			INestedContentProvider {

		public Object[] getConnectedTo(Object entity) {
			if (entity.equals("First")) {
				return new Object[] { "Second" };
			}
			if (entity.equals("Second")) {
				return new Object[] { "Third", "rock" };
			}
			if (entity.equals("Third")) {
				return new Object[] { "First" };
			}
			if (entity.equals("rock")) {
				return new Object[] { "paper" };
			}
			return null;
		}

		public Object[] getElements(Object inputElement) {
			return new String[] { "First", "Second", "Third" };
		}

		public double getWeight(Object entity1, Object entity2) {
			return 0;
		}

		public void dispose() {

		}

		public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {

		}

		public Object[] getChildren(Object element) {
			// TODO Auto-generated method stub
			return new Object[] { "rock", "paper", "scissors" };
		}

		public boolean hasChildren(Object element) {
			// TODO Auto-generated method stub
			if (element.equals("First"))
				return true;
			return false;
		}

	}

	static class MyLabelProvider extends LabelProvider implements
			IFigureProvider {
		final Image image = Display.getDefault().getSystemImage(
				SWT.ICON_WARNING);

		public Image getImage(Object element) {
			if (element.equals("Rock") || element.equals("Paper")
					|| element.equals("Scissors")) {
				return image;
			}
			return null;
		}

		public String getText(Object element) {
			if (element instanceof EntityConnectionData)
				return "";
			return element.toString();
		}

		public IFigure getFigure(Object element) {
			Font classFont = new Font(null, "Arial", 12, SWT.BOLD);
			Image classImage = new Image(Display.getDefault(),
					UMLClassFigure.class.getResourceAsStream("class_obj.gif"));
			Image privateField = new Image(Display.getDefault(),
					UMLClassFigure.class
							.getResourceAsStream("field_private_obj.gif"));
			Image publicField = new Image(Display.getDefault(),
					UMLClassFigure.class.getResourceAsStream("methpub_obj.gif"));
			return createClassFigure1(classFont, classImage, publicField,
					privateField);
		}

	}

	static GraphViewer viewer = null;

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Display d = new Display();
		Shell shell = new Shell(d);
		shell.setText("GraphJFaceSnippet2");
		shell.setLayout(new FillLayout(SWT.VERTICAL));
		shell.setSize(400, 400);
		viewer = new GraphViewer(shell, SWT.NONE);
		viewer.setContentProvider(new MyContentProvider());
		viewer.setLabelProvider(new MyLabelProvider());
		viewer.setLayoutAlgorithm(new SpringLayoutAlgorithm());
		viewer.setInput(new Object());

		Button button = new Button(shell, SWT.PUSH);
		button.setText("push");
		button.addSelectionListener(new SelectionListener() {

			public void widgetDefaultSelected(SelectionEvent e) {
			}

			public void widgetSelected(SelectionEvent e) {
				viewer.setInput(new Object());
			}

		});
		shell.open();
		while (!shell.isDisposed()) {
			while (!d.readAndDispatch()) {
				d.sleep();
			}
		}

	}

}
