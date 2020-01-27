/*******************************************************************************
* Copyright (c) 2011 Stephan Schwiebert. All rights reserved. This program and
* the accompanying materials are made available under the terms of the Eclipse
* Public License v1.0 which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* <p/>
* Contributors: Stephan Schwiebert - initial API and implementation
*******************************************************************************/
package org.eclipse.zest.examples.cloudio.application.actions;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.eclipse.jface.action.IAction;
import org.eclipse.jface.dialogs.ProgressMonitorDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.zest.cloudio.TagCloudViewer;
import org.eclipse.zest.examples.cloudio.application.data.Type;
import org.eclipse.zest.examples.cloudio.application.data.TypeCollector;

/**
 * 
 * @author sschwieb
 *
 */
public class LoadFileAction extends AbstractTagCloudAction {

	@Override
	public void run(IAction action) {
		FileDialog dialog = new FileDialog(getShell(), SWT.OPEN);
		
		dialog.setText("Select text file...");
		String sourceFile = dialog.open();
		if(sourceFile == null) return;
		ProgressMonitorDialog pd = new ProgressMonitorDialog(getShell());
		try {
			List<Type> types = TypeCollector.getData(new File(sourceFile), "UTF-8");
			pd.setBlockOnOpen(false);
			pd.open();
			pd.getProgressMonitor().beginTask("Generating cloud...", 200);
			TagCloudViewer viewer = getViewer();
			viewer.setInput(types, pd.getProgressMonitor());
			//viewer.getCloud().layoutCloud(pd.getProgressMonitor(), false);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			pd.close();
		}
	}

}
