/*******************************************************************************
* Copyright (c) 2011 Stephan Schwiebert. All rights reserved. This program and
* the accompanying materials are made available under the terms of the Eclipse
* Public License v1.0 which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* <p/>
* Contributors: Stephan Schwiebert - initial API and implementation
*******************************************************************************/
package org.eclipse.zest.examples.cloudio.application.actions;

import org.eclipse.jface.action.IAction;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.zest.examples.cloudio.application.data.TypeCollector;

/**
 * 
 * @author sschwieb
 *
 */
public class LoadStopWordsAction extends AbstractTagCloudAction {

	@Override
	public void run(IAction action) {
		FileDialog dialog = new FileDialog(getShell(), SWT.OPEN);
		dialog.setText("Select a stopwor file, containing one word per line...");
		String sourceFile = dialog.open();
		if(sourceFile == null) return;
		TypeCollector.setStopwords(sourceFile);
	}

}
