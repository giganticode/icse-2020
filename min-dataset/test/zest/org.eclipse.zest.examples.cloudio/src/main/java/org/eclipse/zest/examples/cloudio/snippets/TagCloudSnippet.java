/*******************************************************************************
* Copyright (c) 2011 Stephan Schwiebert. All rights reserved. This program and
* the accompanying materials are made available under the terms of the Eclipse
* Public License v1.0 which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* <p/>
* Contributors: Stephan Schwiebert - initial API and implementation
*******************************************************************************/
package org.eclipse.zest.examples.cloudio.snippets;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.zest.cloudio.TagCloud;
import org.eclipse.zest.cloudio.Word;

/**
 * This snippet demonstrates how to create a simple tag cloud,
 * which will display the words "Hello" and "Cloudio".
 * 
 * @author sschwieb
 *
 */
public class TagCloudSnippet {

    public static void main(String [] args) {
        final Display display = new Display();
        final Shell shell = new Shell(display);
        TagCloud cloud = new TagCloud(shell, SWT.NONE);

        // Generate some dummy words - color, weight and fontdata must
        // always be defined.
        List<Word> words = new ArrayList<Word>();
        Word w = new Word("Hello");
        w.setColor(display.getSystemColor(SWT.COLOR_DARK_CYAN));
        w.weight = 1;
        w.setFontData(cloud.getFont().getFontData().clone());
        words.add(w);
        w = new Word("Cloudio");
        w.setColor(display.getSystemColor(SWT.COLOR_DARK_GREEN));
        w.setFontData(cloud.getFont().getFontData().clone());
        w.weight = 0.5;
        w.angle = -45;
        words.add(w);

        shell.setBounds(50,50, 300, 300);
        cloud.setBounds(0,0, shell.getBounds().width, shell.getBounds().height);

        // Assign the list of words to the cloud:
        cloud.setWords(words, null);

        shell.open();
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch()) display.sleep();
        }
        display.dispose();
    }

}
